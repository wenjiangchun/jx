<%@ page contentType="text/html;charset=UTF-8"%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">
    <title></title>
    <link rel="stylesheet" type="text/css" href="res/css/main.css" />
    <style type="text/css">
        #timeline {width: 100%;height: 80px;overflow: hidden;position: absolute;background: url('res/img/dot.gif') left 45px repeat-x;bottom: 0px}
        #dates {width: 760px;height: 80px;overflow: hidden;}
        #dates li {list-style: none;float: left;width: 160px;height: 60px;font-size: 18px;text-align: center;background: url('res/img/biggerdot.png') center bottom no-repeat;}
        #dates a {line-height: 38px;padding-bottom: 10px;}
        #dates .selected {font-size: 28px; color: #d58512}
    </style>
    <script type="text/javascript" src="res/js/jquery.min.js"></script>
    <script type="text/javascript" src="res/js/jquery.timelinr-0.9.53.js"></script>
    <script type="text/javascript">
    </script>
    <style type="text/css">
        html, body
        {
            margin: 0;
            padding: 0;
        }

        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }

        #dasky
        {
            font-family: 'Droid Sans' , sans-serif;
        }

    </style>
    <link rel="stylesheet" href="http://121.42.151.97:8080/arcgis_js_api/library/4.3/4.3/esri/css/main.css">
    <script src="http://121.42.151.97:8080/arcgis_js_api/library/4.3/4.3/init.js"></script>
    <script>
        var myMap = {};
        require([
                "esri/Map",
                "esri/views/SceneView",
                "esri/layers/MapImageLayer",
                "esri/layers/ImageryLayer",
                "esri/layers/TileLayer",
                "esri/layers/Layer",
                "esri/geometry/Extent",
                "esri/layers/FeatureLayer",
                "esri/widgets/LayerList",
                "dojo/domReady!"
            ],
            function(
                Map, SceneView, MapImageLayer,ImageryLayer,TileLayer,Layer,Extent,FeatureLayer,LayerList
            ) {
                jQuery(".wurenji").click(function() {
                    if (!jQuery(this).hasClass("fselected")) {
                        jQuery(".wurenji").removeClass("fselected");
                        jQuery(this).addClass("fselected");
                        initTimeDiv();
                        //添加地图图层
jQuery("#testId").text("自动播放");
                    }
                });
                myMap.setMap = function(map, view) {
                    this.map = map;
                    this.view = view;
                };
                myMap.goTo = function(extent,sourceWkid, targetWkid) {
                    var $this = this;
                    jQuery.post("http://121.42.151.97:6080/arcgis/rest/services/Utilities/Geometry/GeometryServer/project", {
                        inSR:sourceWkid,
                        outSR:targetWkid,
                        geometries:extent,
                        f:"pjson"
                    },function(result) {
                        var geos = result.geometries;
                        if (geos.length > 0) {
                            var extent = new Extent({
                                xmin: geos[0].x,
                                ymin: geos[0].y,
                                xmax: geos[1].x,
                                ymax: geos[1].y,
                                spatialReference: {
                                    wkid: targetWkid
                                }
                            });
                            $this.view.goTo(extent,{
                                duration: 6000,
                                easing: "in-expo"
                            });
                        }
                    },"json");
                };
                jQuery.getJSON("res/js/data3.json",function(result){
                    myMap.datas = result;
                    for (var i = 0; i < result.length; i++) {
                        var data = result[i];
                    }

                    //初始化地图
                    var permitsLyr = new MapImageLayer({
                        url:"http://121.42.151.97:6080/arcgis/rest/services/jsx/MapServer"
                    });
                    /*****************************************************************
                     * Add the layer to a map
                     *****************************************************************/
                    var map = new Map({
                        basemap: "streets",
                        layers: [permitsLyr],
                        ground: "world-elevation"
                    });
                    var view = new SceneView({
                        container: "viewDiv",
                        map: map
                    });
                    // map.layers.addLayer(permitsLyr22);
                    //map.layers.addLayer(permitsLyr22);
                    myMap.setMap(map, view);
                    view.then(function() {
                        permitsLyr.then(function() {
                            view.goTo(permitsLyr.fullExtent);
                            //初始化时间轴
                            jQuery(".wurenji").eq(0).click();
                            
                        });
                    });
                    jQuery("#testId").click(function() {
                        if(myMap.intervalId != undefined) {
                            clearPlay();
                            jQuery("#testId").text("自动播放");
                        } else {
                            jQuery("#testId").text("停止播放");
                            myMap.intervalId = setInterval("autoPlay()", settings.autoPlayPause);
                        }
                    });
                });

                function initTimeDiv() {
                    if(myMap.intervalId != undefined) {
                        clearPlay();
                    }
                    //获取当前选中类型
                    var type = jQuery(".fselected").attr("type");

                    //从数据里获取该类型所有时间轴数据
                    jQuery("#dates").html("");
                    for (var i = 0; i < myMap.datas.length; i++) {
                        var data = myMap.datas[i];
                        if (data.type == type) {
                            //添加地图
                            var sub = [];
                            //查询子图层
                            var subLayers = data.subLayers;
                            var html = "";
                            for (var j = 0; j < subLayers.length; j++) {
                                var date = subLayers[j].date;
                                var dateLevel = subLayers[j].dateLevel;
                                var id = subLayers[j].id;
                                jQuery("#dates").append("<li><a href='javascript:void(0)' date='"+date+"' layerId='" + id + "' parentLayerId='" + data.mapId + "' wkid='" + subLayers[j].wkid + "' extent='" + subLayers[j].extent + "'>"+date+"</a></li>")
                                sub.push({id:subLayers[j].id, visible:j==0?true:false});
                            }
                            var layer = new MapImageLayer({
                                url:data.url,
                                id:data.mapId,
                                sublayers:sub
                            });
                            if (myMap.map.findLayerById(data.mapId) == null) {
                                myMap.map.add(layer,myMap.map.layers.length + 1);
                                layer.then(function() {
                                    //注册时间轴点击事件
                                    $("li>a").click(function() {
                                        var $parentLayerId = $(this).attr("parentLayerId");
                                        var $layerId = $(this).attr("layerId");
                                        //将该类型其它图层隐藏，然后显示对应子图层信息
                                        layer.sublayers.forEach(function(item, i){
                                            if (item.visible) {
                                                item.visible = false;
                                            }
                                        });
                                        //var $sourceWkid = $(this).attr("wkid");
                                        //var $extent = $(this).attr("extent");
                                        var sublayer = layer.findSublayerById(parseInt($layerId));
                                        sublayer.visible = true;
                                        //myMap.goTo($extent, $sourceWkid, 4326);
                                    });
                                });
                            } else {
var ly = myMap.map.findLayerById(data.mapId);
                           //myMap.map.reorder(ly, myMap.map.layers.length);
 //注册时间轴点击事件
ly.sublayers.forEach(function(item, i){
  // Do something here to each graphic like calculate area of its geometry
  if (i == 0) {
   item.visible = true;
} else {
   item.visible = false;
}
});
                                    $("li>a").click(function() {
                                        var $parentLayerId = $(this).attr("parentLayerId");
                                        var $layerId = $(this).attr("layerId");
                                        //将该类型其它图层隐藏，然后显示对应子图层信息
                                        ly.sublayers.forEach(function(item, i){
                                            if (item.visible) {
                                                item.visible = false;
                                            }
                                        });
                                        //var $sourceWkid = $(this).attr("wkid");
                                        //var $extent = $(this).attr("extent");
                                        var sublayer = ly.findSublayerById(parseInt($layerId));
                                        sublayer.visible = true;
                                        //myMap.goTo($extent, $sourceWkid, 4326);
                                    });

}
                        } else {
                            //查询其它图层  然后删除 TODO
                           
                        }
                    }

                    jQuery().timelinr({
                        autoPlay: 'false',
                        autoPlayDirection: 'forward'
                    });
                }
            });
    </script>
</head>
<body>
<img class="title" src="res/images/title.png"  style="position:absolute;top:20px;left:50%;margin-left:-394px;z-index: 999"/>
<div style="width:90px;height:30px;position:absolute;right:2px;top:30px;margin:auto auto;border-radius:5px; z-index: 999"><button id="testId">自动播放</button></div>
<div id="viewDiv"></div>
<div class="wurenji" type="ls" style="width:80px;height:70px;position:absolute;right:10px;top:100px;margin:auto auto;border-radius:5px;">
    <img class="weixing" src="res/images/weixing.png" style="margin-left:18px;margin-top:8px;"/>
</div>
<div class="wurenji"  type="gf" style="width:80px;height:70px;position:absolute;right:10px;top:200px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/gf_pms.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="uav" style="width:80px;height:70px;position:absolute;right:10px;top:300px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/wurenji.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="wt" style="width:80px;height:70px;position:absolute;right:10px;top:400px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/shuizhi.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="br" style="width:80px;height:70px;position:absolute;right:10px;top:500px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/langangpeng.png" style="margin-left:18px;margin-top:4px;" />

</div>

<div id="timeDiv">
    <div id="timeline">
        <ul id="dates">
        </ul></div>
</div>
</body>
</html>
