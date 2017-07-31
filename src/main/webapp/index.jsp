<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">
    <title></title>
    <link rel="stylesheet" href="res/css/dasky.min.css" />
    <link rel="stylesheet" href="res/bootstrap/css/bootstrap.css" />
    <script type="text/javascript" src="res/js/jquery.min.js"></script>
    <script type="text/javascript" src="res/js/jmpress.min.js"></script>
    <script type="text/javascript" src="res/js/dasky.eval.js"></script>
    <script type="text/javascript" src="res/bootstrap/js/bootstrap.js"></script>
    <script type="text/javascript">
        jQuery(function(){
            getData();
            jQuery(".wurenji").click(function() {
                if (jQuery(this).hasClass("fselected")) {
                    jQuery(this).removeClass("fselected");
                } else {
                    jQuery(this).addClass("fselected");
                }
            });
        });
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
                jQuery('#dasky').Dasky();
                //初始化图层数组
                myMap.initLayers = function() {
                    this.layers = [];
                    for (var i = 0; i < this.datas.length; i++) {
                        var data = this.datas[i];
                        var layer = new MapImageLayer({
                            url:data.url
                        });
                        layer.date = data.date;
                        layer.type1 = data.type;
                        this.layers.push(layer);
                    }
                };
                myMap.initLayers();
                myMap.setMap = function(map, view) {
                    this.map = map;
                    this.view = view;
                };

                myMap.removeLayerByType = function(type) {
                    var $this = this.map;
                    this.map.allLayers.forEach(function(item, i) {
                        if (item != undefined && item.type1 === type) {
                            $this.remove(item);
                        }
                    });
                };

                myMap.addLayer = function(date, type) {
                    this.removeLayerByType(type);
                    var $this = this;
                    for (var i = 0; i < this.layers.length; i++) {
                        var layer = this.layers[i];
                        if (layer.type1 === type && layer.date === date) {
                            this.map.add(layer);
                            alert(666);
                            layer.then(function() {
                                alert(777);
                                $this.goTo(layer, 4326, $this.view);
                            });
                        }
                    }
                };

                myMap.removeLayer = function(id) {
                    var foundLayer = this.map.allLayers.find(function(layer) {
                        return layer.id === id;
                    });
                    this.map.remove(foundLayer);
                };

                myMap.goTo = function(layer, targetWkid, view) {
                    jQuery.post("http://121.42.151.97:6080/arcgis/rest/services/Utilities/Geometry/GeometryServer/project", {
                        inSR:layer.spatialReference.wkid,
                        outSR:targetWkid,
                        geometries:"["+layer.fullExtent.xmin+","+layer.fullExtent.ymin+","+layer.fullExtent.xmax+","+layer.fullExtent.ymax+"]",
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
                            view.goTo(extent,{
                                duration: 8000,
                                    easing: "in-expo"
                            });
                        }
                    },"json");
                };

                var permitsLyr = new MapImageLayer({
                    url:"http://121.42.151.97:6080/arcgis/rest/services/test/MapServer"
                });
                var permitsLyr1 = new MapImageLayer({
                    url:"http://121.42.151.97:6080/arcgis/rest/services/test/MapServer"
                });
                /*****************************************************************
                 * Add the layer to a map
                 *****************************************************************/
                var map = new Map({
                    basemap: "streets",
                    layers: [permitsLyr1],
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
                    permitsLyr1.then(function() {
                        view.goTo(permitsLyr1.fullExtent);
                    });
                });

            });

        function getData() {
            jQuery.getJSON("res/js/data.json",function(result){
                myMap.datas = result;
                /*for (var i = 0; i < result.length; i++) {
                    var data = result[i];
                    var year = data.year;
                    if (jQuery("#dasky").find(year).length == 0) {
                        var div = jQuery('<div class="step year ' + year + '">');
                        div.append('<div class="dsk-titlenode">' + year + '</div></div>');
                        //jQuery("#dasky").append(div);
                    }
                    var html = '<div class="step"  date="' +data.date+ '"><div class="dsk-circle">' + data.month + '</div><h2 class="dsk-circle-title"></h2><div class="dsk-content"></div></div>';
                    //jQuery("#dasky").append(html);
                }*/
            });
        }


        function processData(t, s) {
            //获取当前日期
            var date = null;
            if (t[0] != undefined) {
                if (t[0].innerHTML != undefined) {
                    var $div = $(t[0].innerHTML).eq(0);
                    date = $div.attr("date");
                }
            } else {
                    if (t.innerHTML != undefined) {
                        var $div = $(t.innerHTML).eq(0);
                         date = $div.attr("date");
                        //获取当前选中的类型
                        $(".fselected").each(function(e,i) {
                            var $this = $(this);
                            var type = $this.attr("type");
                            //将该类型和该日期的图层叠加到当前地图
                            if (date != undefined && myMap.addLayer != undefined) {
                                if (myMap.map != undefined) {
                                    myMap.addLayer(date, type);
                                }

                            }
                        });
                    }
            }
        }
        myMap.showLayers = function(date) {
            myMap.clearLayers();
            //遍历数据
            for (var i = 0; i < myDatas.length; i++) {
                var data = myDatas[i];
                var type = data.type;
                //判断type状态
                if (data.date == date && jQuery("." + type).length > 0) {
                    //将该图层添加到地图显示
                }
            }
        }
    </script>
</head>
<body>
<div id="dasky" style="position:absolute; bottom: 0px">
    <div class="step year">
        <div class="dsk-titlenode">
            1984
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            1987
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            1990
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            1993
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            1996
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            1999
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2002
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2005
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2008
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2011
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2015
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            01/17</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>
                <p></p>
                <p></p>
            </div>
            <img src="images/ditu_gaode.png" alt="" />
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            05/05</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>
                <p></p>
                <p></p>
            </div>
            <img src="images/ditu_gaode.png" alt="" />
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            05/20</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>
                <p></p>
                <p></p>
            </div>
            <img src="images/ditu_gaode.png" alt="" />
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            10/10</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_tengxun.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            10/11</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_tengxun.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            10/11</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_tengxun.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            12/14</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2016
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            01/01</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            02/02</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            03/05</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            04/14</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            06/01</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            07/22</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            07/27</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            12/02</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            12/07</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step year">
        <div class="dsk-titlenode">
            2017
        </div>
        <div class="dsk-content">
            <p class="dsk-year-info">
            </p>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            01/29</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle" date="2017-2">
            2月</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>

                </h2>
            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            02/14</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            02/28</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>

                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            04/02</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            04/29</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            05/27</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            06</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
    <div class="step">
        <div class="dsk-circle">
            07</div>
        <h2 class="dsk-circle-title">
        </h2>
        <div class="dsk-content">
            <div class="dsk-info" style="background-image:url(images/tanchuang.png);">
                <h2>
                </h2>

            </div>
            <img src="images/ditu_baidu.png"/>
        </div>
    </div>
</div>


<img class="title" src="res/images/title.png"  style="position:absolute;top:20px;left:50%;margin-left:-394px;"/>
<div class="wurenji fselected" type="wx" style="width:80px;height:70px;position:absolute;right:10px;top:100px;margin:auto auto;border-radius:5px;">
    <img class="weixing" src="res/images/weixing.png" style="margin-left:18px;margin-top:8px;" onclick="myMap.removeLayer('jx')"/>
</div>
<div class="wurenji"  type="pms" style="width:80px;height:70px;position:absolute;right:10px;top:200px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/gf_pms.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="wrj" style="width:80px;height:70px;position:absolute;right:10px;top:300px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/wurenji.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="water" style="width:80px;height:70px;position:absolute;right:10px;top:400px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/shuizhi.png" style="margin-left:18px;margin-top:4px;" />
</div>
<div class="wurenji"  type="lgp" style="width:80px;height:70px;position:absolute;right:10px;top:500px;margin:auto auto;border-radius:5px;">
    <img class="wurenji1" src="res/images/langangpeng.png" style="margin-left:18px;margin-top:4px;" />
</div>
</body>
</html>
