<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>组织机构列表</title>
    <link rel="stylesheet" type="text/css" href="${params.contextPath}/common/ztree/css/zTreeStyle/zTreeStyle.css"/>
    <#include "/common/iview_resource.ftl">
    <script type="text/javascript" src="${params.contextPath}/common/ztree/js/jquery.ztree.all.min.js"></script>
    <script type="text/javascript">
        var getSearchParams = function(){
            return {
                searchInput:$("input[name='searchInput']").val() || "",
                parentId:$("input[name='parentId']").val() || "",
            };
        }
        function treeClick(event, treeId, treeNode, clickFlag) {
            $("input[name='parentId']").val(treeNode.id);
            DataGrid.refresh();
        }
        function beforeDrop(treeId, treeNodes, targetNode, moveType, isCopy) {
            var success = false;
            $.ajaxRequest({
                url:"${params.contextPath}/web/organization/drag.json",
                data:{id:treeNodes[0].id, targetId:targetNode.id},
                async:false,
                success:function (data) {
                    if (!data.success) {
                        $.message("拖拽失败");
                        return;
                    }
                    $.message(data.message);
                    success = true;
                }
            });
            return success;
        }

        var setting = {
            data: {simpleData: {enable: true}},
            edit: {
                drag: {autoExpandTrigger: true},
                enable: true,
                showRemoveBtn: false,
                showRenameBtn: false
            },
            callback:{onClick:treeClick,beforeDrop:beforeDrop}
        };
        var initTree = function () {
            $.ajaxRequest({
                url:"${params.contextPath}/web/organization/tree.json",
                success:function (data) {
                    if (!data.success) {
                        $.message(data.message);
                        return;
                    }
                    var zTree = $.fn.zTree.init($("#org-tree"), setting, data.data);
                    var nodes = zTree.transformToArray(zTree.getNodes());
                    zTree.expandNode(nodes[0], true);
                }
            });
        };

        $(document).ready(function(){
            initTree();
            $(".add-dialog").click(function () {
                var treeObj = $.fn.zTree.getZTreeObj("org-tree");
                var nodes = treeObj.getSelectedNodes();
                if (nodes.length <= 0) {
                    var p = $(this).attr("p");
                    DialogManager.openDialog(p);
                    return;
                }
                var parentId = nodes[0].id;
                var p = $(this).attr("p");
                var params = eval("({" + p + "})");
                params.url += "?parentId="+parentId + "&parentName=" + nodes[0].name;
                DialogManager.openDialog(JSON.stringify(params).replace("{", "").replace("}", ""));
            });
            $(".ui-head .right").click(function(){
                var treeObj = $.fn.zTree.getZTreeObj("org-tree");
                treeObj.cancelSelectedNode();
                $("input[name='parentId']").val("");
                DataGrid.refresh();
            });

            new Vue({
                el: '#app-container',
                data: {
                    visible: false,
                    columns1: [
                        {
                            type: 'selection',
                            width: 60,
                            align: 'center',
                            key: 'id',
                        }, {
                            title: 'Name',
                            key: 'name',
                        },
                        {
                            title: 'Age',
                            key: 'age'
                        },
                        {
                            title: 'Address',
                            key: 'address',
                            render: function (h, params) {
                                return h('div', [h('i', params.row.address)]);
                            }
                        }
                    ],
                    data1: [
                        {
                            name: 'John Brown',
                            age: 18,
                            address: 'New York No. 1 Lake Park',
                            date: '2016-10-03'
                        },
                        {
                            name: 'Jim Green',
                            age: 24,
                            address: 'London No. 1 Lake Park',
                            date: '2016-10-01'
                        },
                        {
                            name: 'Joe Black',
                            age: 30,
                            address: 'Sydney No. 1 Lake Park',
                            date: '2016-10-02'
                        },
                        {
                            name: 'Jon Snow',
                            age: 26,
                            address: 'Ottawa No. 2 Lake Park',
                            date: '2016-10-04'
                        }
                    ]
                },
                methods: {
                    show: function () {
                        this.visible = true;
                    }
                }
            })
        });
    </script>
</head>
<body>
<div id="app-container">
    <i-row :gutter="16">
        <i-col span="6">
            <div class="ui-table-left">
                <div class="ui-head">
                    <span>组织机构树</span>
                    <span class="right">
		            	<i class="fa fa-remove"></i>&nbsp;取消选中
		            </span>
                </div>
                <div class="ui-body">
                    <ul id="org-tree" class="ztree"></ul>
                </div>
            </div>
        </i-col>
        <i-col span="18">
            <div class="ui-table-right">
                <div class="ui-operation">
                    <div class="ui-buttons">
                        <div class="tools">
                            <button-group shape="circle" size="small">
                                <i-button type="primary"><icon type="md-add"></icon>&nbsp;添加</i-button>
                                <i-button type="primary"><icon type="md-create"></icon>&nbsp;修改</i-button>
                            </button-group>
                        </div>
                        <#--<div class="layui-btn-group tools">
                            <button class="layui-btn layui-btn-normal add-dialog"  p="url:'${params.contextPath}/view/organization/org_edit.htm',title:'添加组织机构',width:'800px',height:'90%'"><i class="fa fa-plus"></i>添加</button>
                            <button class="layui-btn layui-btn-normal singleSelected" p="url:'${params.contextPath}/view/organization/org_edit.htm',title:'修改组织机构',width:'800px',height:'90%'"><i class="fa fa-pencil"></i>修改</button>
                        </div>-->
                        <div class="ui-searchs">
                            <i-input search enter-button="搜索" name="searchInput" placeholder="编码、名称" />
                            <input type="hidden" name="parentId" value=""/>
                        </div>
                    </div>
                </div>
                <div class="ui-content" style="padding-left: 10px;padding-right:10px;">
                    <i-Table stripe border size="small" :columns="columns1" :data="data1"></i-Table>
                    <Page :total="4000000" size="small" show-elevator show-sizer show-total/>
                </div>
            </div>
        </i-col>
    </i-row>
</div>
    <#--<table class="ui-table">
        <tr>
            <td class="ui-table-left" style="width:300px;">
                <!-- ** 左侧栏 ** &ndash;&gt;
                <div class="ui-head">
                    <span>组织机构树</span>
                    <span class="right">
		            	<i class="fa fa-remove"></i>&nbsp;取消选中
		            </span>
                </div>
                <div class="ui-body">
                    <ul id="org-tree" class="ztree"></ul>
                </div>
            </td>
            <td class="ui-table-right" >
                <div class="ui-operation">
                    <div class="ui-buttons">
                        <div class="layui-btn-group tools">
                            <button class="layui-btn layui-btn-normal add-dialog"  p="url:'${params.contextPath}/view/organization/org_edit.htm',title:'添加组织机构',width:'800px',height:'90%'"><i class="fa fa-plus"></i>添加</button>
                            <button class="layui-btn layui-btn-normal singleSelected" p="url:'${params.contextPath}/view/organization/org_edit.htm',title:'修改组织机构',width:'800px',height:'90%'"><i class="fa fa-pencil"></i>修改</button>
                        </div>
                        <div class="ui-searchs">
                            <div class="value">
                                <input type="text" name="searchInput" value="" placeholder="编码、名称"/>
                                <input type="hidden" name="parentId" value=""/>
                            </div>
                            <input type="button" value="搜索" class="layui-btn layui-btn-danger search-button"/>
                        </div>
                    </div>
                </div>
                <div class="ui-content" style="padding-left: 10px;padding-right:10px;">
                    <table id="datagrid" options="url:'${params.contextPath}/web/organization/list.json',params:'getSearchParams'">
                        <thead>
                            <tr>
                                <th data-options="field:'id',checkbox:true">Item ID</th>
                                <th data-options="field:'code',width:120">编码</th>
                                <th data-options="field:'name',width:200">名称</th>
                                <th data-options="field:'categoryStr',width:120">类别</th>
                                &lt;#&ndash;<th data-options="field:'areaName',width:80">所在区域</th>&ndash;&gt;
                                <th data-options="field:'telephone',width:100">联系电话</th>
                                <th data-options="field:'ordernum',width:60">显示序号</th>
                                <th data-options="field:'createTimeStr',width:150,align:'center'">创建时间</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </td>
        </tr>
    </table>-->
</body>
</html>
