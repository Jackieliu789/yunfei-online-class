<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${params.websitName!}</title>
    <link rel="stylesheet" type="text/css" href="https://www.layuicdn.com/layui-v2.5.6/css/layui.css"/>

    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
    <script type="text/javascript" src="https://cdn.bootcss.com/jquery/3.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script type="text/javascript" src="${params.contextPath}/js/trtc.js"></script>
    <style>
        body, html, #app {margin: 0;height: 100%;}
        [v-cloak]{display:none !important;}
        .header{height:30px;line-height:30px;color:#fff;font-size:14px;position:fixed;top:10px;right:0;left:0;text-align:center;z-index:10}
        .header .title{background:rgba(255,255,255,0.2);text-align:center;margin:0 auto;display:inline-block;padding:0 30px;border-radius:15px;}
        .video-box, .screen-box{height:100%;}
        .small-box{position:fixed;top:20px;right:20px;width:200px;height:150px;z-index:10}
        .tools-box{position:fixed;bottom:20px;right:0;left:0;z-index:10}
        .tools-container{margin:0 auto;text-align:center;background:rgba(255,255,255,0.2);width:300px;border-radius:5px;}
        .tools-container .item{display:inline-block;color:#fff;padding:10px 15px;font-size:12px;color:#ddd;cursor:pointer;}
        .tools-container .item img{width:20px;margin-bottom:5px;}
        .tools-container .item > div{font-size:12px;}
        .video-setting{position:absolute;top:50%; left:50%;margin-top:-250px;margin-left:-350px;z-index:210;border:5px solid #009688;border-radius:8px;}
        .setting-row{box-shadow:0 6px 18px 0 rgba(0,0,0,.2);background:#fff;border-radius:8px;width:700px;height:500px;}
        .setting{padding:50px 40px;}
        .setting .item{margin-bottom:40px;}
        .setting .title{color:rgba(0, 0, 0, 0.54);font-size:12px;margin-bottom:5px;}
        .setting .input select{width:100%;font-size:18px;line-height:40px;height:40px;border:none;border-bottom:1px solid #eee;color:rgba(0, 0, 0, 0.8);}
        #setting-video{height:100%;}
        #setting-video .warn-msg{margin-top: 20px;text-align:center}
        .white-show{background: rgba(0,0,0,0.5) !important;}
        @media screen and (max-width:768px ) {
            .video-setting{top:0;right:0;bottom:0;left:0;overflow:auto;background:#fff;margin-top:0;margin-left:0;position:fixed;}
            .setting-row{width:100%;}
        }
    </style>
</head>
<body>
<div id="app" v-cloak>
    <div class="header">
        <div :class="videoStream ? 'title' : 'title white-show'">${params.n!'-'}</div>
    </div>
    <div :class="screenStream ? 'video-box small-box' : 'video-box'" id="video-box"></div>
    <div class="screen-box" id="screen-box" v-if="screenStream"></div>
    <div class="tools-box">
        <div :class="videoStream ? 'tools-container' : 'tools-container white-show'">
            <div class="item" v-if="!screenStream" @click="bindShowShareScreen">
                <div><img src="${params.contextPath!}/images/screen.png" alt=""></div>
                <div>共享屏幕</div>
            </div>
            <div class="item" v-if="!videoStream" @click="bindAttendClass">
                <div><img src="${params.contextPath!}/images/live_class.png" alt=""></div>
                <div>上课</div>
            </div>
            <div class="item" v-if="videoStream" @click="bindOverClass">
                <div><img src="${params.contextPath!}/images/ove_class.png" alt=""></div>
                <div>下课</div>
            </div>
            <div class="item" v-if="videoStream" @click="bindToggleSetting">
                <div><img src="${params.contextPath!}/images/seeting.png" alt=""></div>
                <div>设置</div>
            </div>
            <div class="item" @click="signOut">
                <div><img src="${params.contextPath!}/images/signout.png" alt=""></div>
                <div>退出</div>
            </div>
        </div>
    </div>

    <#--音视频设置-->
    <div class="video-setting" v-if="showVideoSetting">
        <div class="layui-row setting-row">
            <div class="layui-col-md6" id="setting-video"><div class="warn-msg text-center" v-if="!videoStream">暂无本地视频</div></div>
            <div class="layui-col-md6 setting">
                <div class="item">
                    <div class="title">摄像头</div>
                    <div class="input">
                        <select @change="changeVideoinput($event)">
                            <option v-for="(item,index) in videoinputs" :key="index" :value='item.deviceId'>{{item.label}}</option>
                        </select>
                    </div>
                </div>
                <div class="item">
                    <div class="title">麦克风</div>
                    <div class="input">
                        <select @change="changeAudioinput($event)">
                            <option v-for="(item,index) in audioinputs" :key="index" :value='item.deviceId'>{{item.label}}</option>
                        </select>
                    </div>
                </div>
                <div class="item">
                    <div class="title">扬声器</div>
                    <div class="input">
                        <select>
                            <option v-for="(item,index) in audiooutputs" :key="index" :value='item.deviceId'>{{item.label}}</option>
                        </select>
                    </div>
                </div>
                <button type="button" class="layui-btn layui-btn-fluid layui-btn-radius layui-btn-normal" @click="bindCloseSetting" style="height:44px;line-height:44px;">完成</button>
            </div>
        </div>
    </div>
</div>
<script>
    var app = new Vue({
        el: '#app',
        data: {
            videoClient: null,
            videoStream: null,

            screenClient: null,
            screenStream: null,

            cId:'${params.cid!}',
            userId: '${(user.id)!}',
            screenId: '${(user.id)!}_screen',
            webrtcId: ${params.videoKey!0},
            roomId:${params.rid!''},
            videoSig: '${params.s!}',
            screenSig: '${params.sc!}',

            showVideoSetting: false,

            videoinputs: [],//摄像头
            audioinputs: [],//麦克风
            audiooutputs: [],//扬声器
        },
        mounted: function () {
        },
        methods: {
            getDevices: function () {
                var that = this;
                TRTC.getDevices().then(function (devices) {
                    var options = {audiooutput: [], audioinput: [], videoinput: []};
                    for (var i = 0; i < devices.length; i++) {
                        var device = devices[i];
                        options[device.kind].push({deviceId: device.deviceId, label: (device.label || "设备-" + i)});
                    }
                    that.audiooutputs = options.audiooutput;
                    that.audioinputs = options.audioinput;
                    that.videoinputs = options.videoinput;
                }, function (errStr) {
                    $.message("获取设备信息失败：" + JSON.stringify(errStr));
                });
            },
            initVideo: function () {//初始化视频
                if (!this.webrtcId) {
                    $.message("音视频Key未配置，无法初始化音视频");
                    return;
                }
                var that = this;
                this.videoClient = TRTC.createClient({
                    mode: 'live',
                    sdkAppId: this.webrtcId,
                    userId: this.userId,
                    userSig: this.videoSig
                });
                this.videoClient.join({roomId: this.roomId, role: 'anchor'}).then(function () {
                    console.log('进房成功');
                    that.subscribeVideoEvents();
                    that.videoStream = TRTC.createStream({userId: that.userId, audio: true, video: true});
                    that.videoStream.setVideoProfile('480p');
                    that.videoStream.initialize().then(function () {
                        that.getDevices();
                        that.publishVideo();
                        console.log('初始化本地流成功');
                    }).catch(function (error) {
                        that.videoClient && that.videoClient.leave();
                        that.videoClient = null;
                        that.videoStream = null;
                        console.error('初始化本地流失败 ' + error);
                    });
                }).catch(function (error) {
                    that.videoClient = null;
                    console.error('进房失败 ' + error);
                    alert('进房失败');
                });
            },
            publishVideo: function () {
                var that = this;
                this.videoClient.publish(this.videoStream).then(function () {
                    that.videoStream.play("video-box", {objectFit1: "contain"});
                }).catch(function (error) {
                    that.videoStream = null;
                    console.error('本地流发布失败：' + error);
                    alert('本地流发布失败');
                });
            },
            subscribeVideoEvents: function () {
                var that = this;
                //远端流移除
                this.videoClient.on('stream-removed', function (event) {
                    var stream = event.stream;
                    if (stream.getUserId() == that.screenId) {
                        that.closeScreen();
                    }
                });
            },
            initScreen: function () {
                var that = this;
                if (!this.webrtcId) {
                    alert("音视频Key未配置，无法初始化音视频");
                    return;
                }
                alert("请不要共享当前窗口，防止出现画中画现象");
                this.showShareScreen = true;
                this.screenClient = TRTC.createClient({
                    mode: 'live',
                    sdkAppId: this.webrtcId,
                    userId: this.screenId,
                    userSig: this.screenSig
                });
                this.screenClient.join({roomId: this.roomId, role: 'anchor'}).catch(function (error) {
                    that.screenClient = null;
                    console.error('进房失败 ' + error);
                    alert('进房失败');
                }).then(function () {
                    console.log('进房成功');
                    that.screenStream = TRTC.createStream({userId: that.userId, audio: false, screen: true});
                    that.screenStream.on('screen-sharing-stopped', function (event) {
                        that.closeScreen();
                        console.log('screen sharing was stopped');
                    });
                    that.screenStream.setScreenProfile('720p_2');
                    that.screenStream.initialize().then(function () {
                        that.screenClient.publish(that.screenStream).then(function () {
                            that.screenStream.play("screen-box", {objectFit1: "contain"});
                        }).catch(function (error) {
                            that.closeScreen();
                            console.error('本地共享桌面流发布失败：' + error);
                            alert('本地共享桌面流发布失败');
                        });
                        console.log('初始化本地流成功');
                    }).catch(function (error) {
                        console.error('初始化本地流失败 ' + error);
                        that.closeScreen();
                    });
                });
            },
            closeScreen:function(){
                this.screenStream && this.screenStream.close();
                this.screenClient && this.screenClient.leave();
                this.screenClient = null;
                this.screenStream = null;
            },
            bindAttendClass:function () {
                this.initVideo();
            },
            leaveRoom: function () {//离开频道
                var that = this;
                this.videoClient && this.videoClient.leave().then(function () {
                    that.videoClient = null;
                    console.log("退出成功");
                }).catch(function (error) {
                    console.error('leaving room failed: ' + error);
                });

                this.screenClient && this.screenClient.leave().then(function () {
                    that.screenClient = null;
                    console.log("退出成功");
                }).catch(function (error) {
                    console.error('leaving room failed: ' + error);
                });
            },
            bindOverClass:function () {
                this.screenStream && this.screenStream.close();
                this.screenStream = null;
                this.videoStream && this.videoStream.close();
                this.videoStream = null;
                this.leaveRoom();
            },
            bindShowShareScreen: function () {
                if (this.screenStream) {
                    $.message("屏幕真正共享中");
                    return;
                }
                if (this.showMaxHost) {
                    this.bindCloseMaxHost();
                }
                this.$nextTick(function () {
                    this.initScreen();
                });
            },
            bindToggleSetting: function () {
                if (this.showVideoSetting) {
                    this.bindCloseSetting();
                    return;
                }
                this.showVideoSetting = true;
                this.$nextTick(function () {
                    this.videoStream && this.videoStream.stop();
                    this.videoStream && this.videoStream.play("setting-video"/*, {objectFit1: "contain"}*/);
                });
            },
            bindCloseSetting: function () {
                this.videoStream && this.videoStream.stop();
                this.videoStream && this.videoStream.play("video-box", {objectFit1: "contain"});
                this.showVideoSetting = false;
            },
            signOut:function () {
                var that = this;
                $.http.post("${params.contextPath}/web/participateUser/save.json", {
                    roomId: this.cId
                }).then(function (data) {
                    if (!data.success) {
                        $.message(data.message);
                        return;
                    }
                    that.bindOverClass();
                    window.close();
                });
            },
            changeVideoinput:function(e){
                var deviceId = e.target.value;
                if (this.videoStream) {
                    this.videoStream.switchDevice('video', deviceId).then(function () {
                        $.message("切换摄像头成功！");
                    }).catch(function (err) {
                        $.message("切换摄像头失败：" + JSON.stringify(err));
                    });
                }
            },
            changeAudioinput:function(e){
                var deviceId = e.target.value;
                if (this.videoStream) {
                    this.videoStream.switchDevice('audio', deviceId).then(function () {
                        $.message("切换麦克风成功！");
                    }).catch(function (err) {
                        $.message("切换麦克风失败：" + JSON.stringify(err));
                    });
                }
            },
        }
    });
</script>
</body>

</html>
