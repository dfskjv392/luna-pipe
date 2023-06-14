<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/jsp/lunaops/top/header.jsp" %>

<link rel='stylesheet' href='<c:url value='/css/lunaops/stm.css'/>' type='text/css'>
<style type="text/css">
	.accptFont{color:#4b73eb !important;text-shadow: none !important;}
	.rejectFont{color:#eb4b6a !important;text-shadow: none !important;}
	.defaultFont{color:#000 !important;}
	
</style>
<script>
var leftGrid,rightGrid;
var mySearchLeft,mySearchRight;


$(function(){
	
	fnAxGrid5ViewLeft();
	fnSearchBoxControlLeft();
	
	
	fnAxGrid5ViewRight();
	fnSearchBoxControlRight();
	
	
	gfnGuideStack("add",fnStm3000GuideShow);
});



function fnSelectChg(){
	var selVal = $("#searchSelect option:selected").val();
	if(selVal == '0'){
		$("#searchTxt").val("");
		$("#searchTxt").attr("readonly", true);
	}else{
		$("#searchTxt").attr("readonly", false);
	}
}


function fnAxGrid5ViewLeft(){
	leftGrid = new ax5.ui.grid();
 
        leftGrid.setConfig({
            target: $('[data-ax5grid="grid_left"]'),
            
            sortable:false,
            header: {align:"center",columnHeight: 30},
            columns: [
				{key: "result", label: " ", width: 30, align: "center"
					,formatter:function(){
						var result = this.item.result;
						var faIcon = '';
						
						
						if(result == "fail"){
							faIcon = "times-circle";
						}
						else if(result == "success"){
							faIcon = "check-circle";
						}else if(result == "progress"){
							faIcon = "circle-notch fa-spin";
						}else{
							faIcon = "circle";
						}
						
						return '<i class="fas fa-'+faIcon+' result-'+result+'"></i>';
					}},
				{key: "jenNm", label: "JENKINS NAME", width: 180, align: "center"},
				{key: "jenUrl", label: "JENKINS URL", width: 280, align: "left"},
				{key: "jenUsrId", label: "JENKINS USER ID", width: 130, align: "center"},
				{key: "useNm", label: "사용유무", width: 85, align: "center"}
            ],
            body: {
                align: "center",
                columnHeight: 30,
                onClick:function(){
                	
                    this.self.select(leftGrid.selectedDataIndexs[0]);
                	
                	
                    this.self.select(this.doindex);
                	
                	 
 					fnInRightGridListSet(0,mySearchRight.getParam()+"&jenId="+this.item.jenId,false);
                },
                onDBLClick:function(){
                		var data = {"jenNm": this.item.jenNm,"jenId": this.item.jenId, "jenUrl": this.item.jenUrl, "jenUsrId":this.item.jenUsrId, "jenUsrTok": this.item.jenUsrTok};
						gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3003JenkinsDetailView.do',data,"1200","595",'scroll');
                }
            },
            contextMenu: {
        		iconWidth: 20,
        		acceleratorWidth: 100,
        		itemClickAndClose: false,
        		icons: {'arrow': '<i class="fa fa-caret-right"></i>'},
        		items: [
        			{type: "usrDetailPopup", label: "JENKINS 저장소 등록자 상세 정보", icon:"<i class='fa fa-info-circle' aria-hidden='true'></i>"}
        		],
        		popupFilter: function (item, param) {
        			
        			
        			if(typeof param.item == "undefined"){
          				return false;
         			}
        				return true;
        			},
        		onClick: function (item, param) {
        			var selItem = param.item;
        			
        			if(item.type == "usrDetailPopup"){
                  		if(gfnIsNull(selItem.regUsrId)){
                			jAlert('JENKINS 저장소 등록자가 없습니다.','알림창');
        					return false;
                		}else{
                			var data = {"usrId": param.item.regUsrId}; 
        					gfnLayerPopupOpen("/cmm/cmm1000/cmm1900/selectCmm1900View.do", data, "500", "370",'auto');
                		}
                	}
        			
        			param.gridSelf.contextMenu.close();
        		}
        	},
            page: {
                navigationItemCount: 9,
                height: 30,
                display: true,
                firstIcon: '<i class="fa fa-step-backward" aria-hidden="true"></i>',
                prevIcon: '<i class="fa fa-caret-left" aria-hidden="true"></i>',
                nextIcon: '<i class="fa fa-caret-right" aria-hidden="true"></i>',
                lastIcon: '<i class="fa fa-step-forward" aria-hidden="true"></i>',
                onChange: function () {
                   fnInLeftGridListSet(this.page.selectPage,mySearchLeft.getParam());
                }
            } 
        });
        
 		fnInLeftGridListSet();
}


function fnInLeftGridListSet(_pageNo,ajaxParam){
     	
     	
     	if(gfnIsNull(ajaxParam)){
   			ajaxParam = $('form#searchFrm').serialize();
   		}
     	
     	
     	if(!gfnIsNull(_pageNo)){
     		ajaxParam += "&pageNo="+_pageNo;
     	}else if(typeof leftGrid.page.currentPage != "undefined"){
     		ajaxParam += "&pageNo="+leftGrid.page.currentPage;
     	}
     	
     	
		var ajaxObj = new gfnAjaxRequestAction(
				{"url":"<c:url value='/stm/stm3000/stm3000/selectStm3000JenkinsListAjax.do'/>","loadingShow":true}
				,ajaxParam);
		
		ajaxObj.setFnSuccess(function(data){
			data = JSON.parse(data);
			var list = data.list;
			var page = data.page;
			
		   	leftGrid.setData({
		             	list:list,
		             	page: {
		                  currentPage: _pageNo || 0,
		                  pageSize: page.pageSize,
		                  totalElements: page.totalElements,
		                  totalPages: page.totalPages
		              }
		             });
		});
		
		
		ajaxObj.setFnError(function(xhr, status, err){
			
           	if(status == "999"){
           		alert('세션이 만료되어 로그인 페이지로 이동합니다.');
        		document.location.href="<c:url value='/cmm/cmm4000/cmm4000/selectCmm4000View.do'/>";
        		return;
           	}
		});
		
		
		ajaxObj.send();
}


function fnAxGrid5ViewRight(){
	rightGrid = new ax5.ui.grid();
 
        rightGrid.setConfig({
            target: $('[data-ax5grid="grid_right"]'),
            showRowSelector: true,
            sortable:false,
            header: {align:"center",columnHeight: 30},
            columns: [
				{key: "result", label: " ", width: 30, align: "center"
					,formatter:function(){
						var result = this.item.result;
						var faIcon = '';
						
						
						if(result == "fail"){
							faIcon = "times-circle";
						}
						else if(result == "success"){
							faIcon = "check-circle";
						}else if(result == "progress"){
							faIcon = "circle-notch fa-spin";
						}else{
							faIcon = "circle";
						}
						
						return '<i class="fas fa-'+faIcon+' result-'+result+'"></i>';
					}},
				{key: "jobTypeNm", label: "JOB TYPE", width: 95, align: "center"},
				{key: "jobId", label: "JOB ID", width: 170, align: "center"},
				{key: "jobRestoreId", label: "원복 JOB ID", width: 170, align: "center"},
				{key: "jobParameter", label: "JOB 매개변수", width: 150, align: "center"
					,formatter:function(){
						var jobParameter = this.item.jobParameter;
						
						if(gfnIsNull(jobParameter)){
							jobParameter = '-';
						}
						return jobParameter;
					}
				},
				
				{key: "useNm", label: "사용유무", width: 80, align: "center"}
            ],
            body: {
                align: "center",
                columnHeight: 30,
                onDBLClick:function(){
                		var data = {"jenId": this.item.jenId, "jobId": this.item.jobId};
						gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3004JobDetailView.do',data,"1200", "870",'scroll');
                }
            } ,
            page: {
                navigationItemCount: 9,
                height: 30,
                display: true,
                firstIcon: '<i class="fa fa-step-backward" aria-hidden="true"></i>',
                prevIcon: '<i class="fa fa-caret-left" aria-hidden="true"></i>',
                nextIcon: '<i class="fa fa-caret-right" aria-hidden="true"></i>',
                lastIcon: '<i class="fa fa-step-forward" aria-hidden="true"></i>',
                onChange: function () {
                	var item = leftGrid.getList('selected')[0];
					if(gfnIsNull(item)){
						toast.push('좌측 목록에서 JENKINS를 선택해주세요.');
						return;
					}
					
					
		            fnInRightGridListSet(this.page.selectPage,mySearchRight.getParam()+"&jenId="+item.jenId,true);
                }
            } 
        });
}


function fnInRightGridListSet(_pageNo,ajaxParam,loadingShow){
     	
     	
     	if(gfnIsNull(ajaxParam)){
   			ajaxParam = $('form#searchFrm').serialize();
   		}
     	
     	
     	if(!gfnIsNull(_pageNo)){
     		ajaxParam += "&pageNo="+_pageNo;
     	}else if(typeof leftGrid.page.currentPage != "undefined"){
     		ajaxParam += "&pageNo="+rightGrid.page.currentPage;
     	}
     	
     	
		var ajaxObj = new gfnAjaxRequestAction(
				{"url":"<c:url value='/stm/stm3000/stm3000/selectStm3000JobListAjax.do'/>","loadingShow":loadingShow}
				,ajaxParam);
		
		ajaxObj.setFnSuccess(function(data){
			data = JSON.parse(data);
			var list = data.list;
			var page = data.page;
			
		   	rightGrid.setData({
		             	list:list,
		             	page: {
		                  currentPage: _pageNo || 0,
		                  pageSize: page.pageSize,
		                  totalElements: page.totalElements,
		                  totalPages: page.totalPages
		              }
		             });
		});
		
		
		ajaxObj.setFnError(function(xhr, status, err){
			
           	if(status == "999"){
           		alert('세션이 만료되어 로그인 페이지로 이동합니다.');
        		document.location.href="<c:url value='/cmm/cmm4000/cmm4000/selectCmm4000View.do'/>";
        		return;
           	}
		});
		
		
		ajaxObj.send();
}



function fnDeleteStm3000JenkinsInfo(jenId){
	
	var ajaxObj = new gfnAjaxRequestAction(
			{"url":"<c:url value='/stm/stm3000/stm3000/deleteStm3000JenkinsInfoAjax.do'/>"}
			,{ "jenId" : jenId });
	
	ajaxObj.setFnSuccess(function(data){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
		fnInLeftGridListSet();
		
		var gridList = rightGrid.getList();
		if(!gfnIsNull(gridList) && gridList.length > 0){
			$.each(gridList,function(){
				rightGrid.removeRow(0);
			});
		}
	});
	
	
	ajaxObj.setFnError(function(xhr, status, err){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
	});
	
	
	ajaxObj.send();
} 


function fnDeleteStm3000JobInfo(jenId, jobId){
	
	var ajaxObj = new gfnAjaxRequestAction(
			{"url":"<c:url value='/stm/stm3000/stm3000/deleteStm3000JobInfoAjax.do'/>"}
			,{ "jenId" : jenId, "jobId" : jobId });
	
	ajaxObj.setFnSuccess(function(data){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
		fnInRightGridListSet(0,mySearchRight.getParam()+"&jenId="+jenId);
	});
	
	
	ajaxObj.setFnError(function(xhr, status, err){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
	});
	
	
	ajaxObj.send();
} 


function fnSearchBoxControlLeft(){
	mySearchLeft = new AXSearch();

	var fnObjSearch = {
		pageStart: function(){
			
			mySearchLeft.setConfig({
				targetID:"AXSearchTarget_left",
				theme : "AXSearch",
				rows:[
					{display:true, addClass:"", style:"", list:[
						{label:"<i class='fa fa-search'></i>&nbsp;", labelWidth:"30", type:"selectBox", width:"", key:"searchSelect", addClass:"", valueBoxStyle:"", value:"all",
							options:[
                                {optionValue:"0", optionText:"전체 보기",optionAll:true},
                                {optionValue:'jenNm', optionText:'Jenkins 명'},
                                {optionValue:'jenDesc', optionText:'Jenkins 설명'},
                                {optionValue:'useCd', optionText:'사용 여부' , optionCommonCode:"CMM00001" }                                
                                
                            ],onChange: function(selectedObject, value){
                            	
    							if(!gfnIsNull(selectedObject.optionAll) && selectedObject.optionAll == true){
									axdom("#" + mySearchLeft.getItemId("searchTxt")).attr("readonly", "readonly");	
									axdom("#" + mySearchLeft.getItemId("searchTxt")).val('');	
								}else{
									axdom("#" + mySearchLeft.getItemId("searchTxt")).removeAttr("readonly");
								}
								
								
								if(!gfnIsNull(selectedObject.optionCommonCode)){
									gfnCommonSetting(mySearchLeft,selectedObject.optionCommonCode,"searchCd","searchTxt");
								}else{
									
									axdom("#" + mySearchLeft.getItemId("searchTxt")).show();
									axdom("#" + mySearchLeft.getItemId("searchCd")).hide();
								}
    						},

						},
						{label:"", labelWidth:"", type:"inputText", width:"120", key:"searchTxt", addClass:"secondItem sendBtn", valueBoxStyle:"padding-left:0px;", value:"",
							onkeyup:function(e){
								if(e.keyCode == '13' ){
									axdom("#" + mySearchLeft.getItemId("btn_search_jenkins")).click();
								}
							} 
						},
						{label:"", labelWidth:"", type:"selectBox", width:"100", key:"searchCd", addClass:"selectBox", valueBoxStyle:"padding-left:0px;", value:"01",
							options:[]
						},
						
						
						{label:"<i class='fas fa-list-ol'></i>&nbsp;목록 수&nbsp;", labelWidth:"60", type:"selectBox", width:"", key:"pageSize", addClass:"", valueBoxStyle:"", value:"30",
							options:[
							         	{optionValue:15, optionText:"15"},
		                                {optionValue:30, optionText:"30"},
		                                {optionValue:50, optionText:"50"},
		                                {optionValue:100, optionText:"100"},
		                                {optionValue:300, optionText:"300"},
		                                {optionValue:600, optionText:"600"},
		                                {optionValue:1000, optionText:"1000"},
		                                {optionValue:5000, optionText:"5000"},
		                                {optionValue:10000, optionText:"10000"},
		                                
		                            ],onChange: function(selectedObject, value){
		                            	fnInLeftGridListSet(0,$('form#searchFrm').serialize()+"&"+mySearchLeft.getParam());
		    						}
						},
						{label:"<i class='fas fa-arrows-alt-v'></i>&nbsp;목록 높이&nbsp;", labelWidth:"60", type:"selectBox", width:"", key:"gridHeight", addClass:"", valueBoxStyle:"", value:"600",
							options:[
							         	{optionValue:300, optionText:"300px"},
		                                {optionValue:600, optionText:"600px"},
		                                {optionValue:1000, optionText:"1000px"},
		                                {optionValue:1200, optionText:"1200px"},
		                                {optionValue:2000, optionText:"2000px"},
		                                
		                            ],onChange: function(selectedObject, value){
		                            	leftGrid.setHeight(value);
		    						}
						},
						{label:"", labelWidth:"", type:"button", width:"80",style:"float:right;", key:"btn_search_jenkins_connect",valueBoxStyle:"padding:5px;", value:"<span>전체 접속확인</span>",
       							onclick:function(){
       								
       								var gridLen = leftGrid.getList().length;
       								
       								
       								if(gridLen > 0){
       									
       									fnSelectStm3000AllConfirmConnect(0);
       								}
                    	}}
					]},
					{display:true, addClass:"", style:"", list:[
                    						
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_print_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-print' aria-hidden='true'></i>&nbsp;<span>프린트</span>",
							onclick:function(){
								$(leftGrid.exportExcel()).printThis({importCSS: false,importStyle: false,loadCSS: "/css/common/printThis.css"});
						}},
						{label:"", labelWidth:"", type:"button", width:"55",style:"float:right;", key:"btn_excel_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-file-excel' aria-hidden='true'></i>&nbsp;<span>엑셀</span>",
							onclick:function(){
								leftGrid.exportExcel("JENKINS_LIST.xls");
						}},
						{label : "",labelWidth : "",type : "button",width : "55",key : "btn_delete_jenkins",style : "float:right;",valueBoxStyle : "padding:5px;",value : "<i class='fa fa-trash-alt' aria-hidden='true'></i>&nbsp;<span>삭제</span>",
							onclick : function() {
								var item = leftGrid.getList('selected')[0];
								if(gfnIsNull(item)){
									toast.push('삭제 할 목록을 선택하세요.');
									return;
								}
								jConfirm("JENKINS를 삭제하시겠습니까?</br>연관된 모든 정보가 함께 삭제됩니다.", "알림창", function( result ) {
									if( result ){
										fnDeleteStm3000JenkinsInfo(item.jenId);
									}
								});
							}
						},
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_update_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-edit' aria-hidden='true'></i>&nbsp;<span>수정</span>",
							onclick:function(){
								var item = leftGrid.getList('selected')[0];
								if(gfnIsNull(item)){
									toast.push('수정 할 목록을 선택하세요.');
									return;
								}
								
								var data = {"popupGb": "update", "jenId": item.jenId};
        	                	
								gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3001JenkinsDetailView.do',data,"650","735",'scroll');
						}},
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_insert_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-save' aria-hidden='true'></i>&nbsp;<span>등록</span>",
							onclick:function(){
								var data = {
									"popupGb": "insert"
								};
								gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3001JenkinsDetailView.do',data,"650","590",'scroll');
						}},
						{label:"", labelWidth:"", type:"button", width:"55", key:"btn_search_jenkins",style:"float:right;",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-list' aria-hidden='true'></i>&nbsp;<span>조회</span>",
							onclick:function(){
								
					            fnInLeftGridListSet(0,mySearchLeft.getParam());
						}},
						{label:"", labelWidth:"", type:"button", width:"100",style:"float:right;", key:"btn_search_jenkins_connect",valueBoxStyle:"padding:5px;", value:"<i class='fas fa-angle-double-right' aria-hidden='true'></i>&nbsp;<span>선택 접속확인</span>",
       							onclick:function(){
       								var item = leftGrid.getList('selected')[0];
       								if(gfnIsNull(item)){
       									toast.push('확인 할 목록을 선택하세요.');
       									return;
       								}
       								fnSelectStm3000ConfirmConnect(item.jenId,  leftGrid.getList('selected')[0].__index );
                    	}}
                    	]
                  		},
				]
			});
		}
		
	};
	
	jQuery(document.body).ready(function(){
		
		fnObjSearch.pageStart();
		
		axdom("#" + mySearchLeft.getItemId("searchTxt")).attr("readonly", "readonly");
		
		
		axdom("#" + mySearchLeft.getItemId("searchCd")).hide();

		
		fnBtnAuthCheck(mySearchLeft);
	});
}


function fnSearchBoxControlRight(){
	mySearchRight = new AXSearch();

	var fnObjSearch = {
		pageStart: function(){
			
			mySearchRight.setConfig({
				targetID:"AXSearchTarget_right",
				theme : "AXSearch",
				rows:[
					{display:true, addClass:"", style:"", list:[
						{label:"<i class='fa fa-search'></i>&nbsp;", labelWidth:"30", type:"selectBox", width:"", key:"searchSelect", addClass:"", valueBoxStyle:"", value:"all",
							options:[
                                {optionValue:"0", optionText:"전체 보기",optionAll:true},
                                {optionValue:'jobId', optionText:'JOB ID'},
                                {optionValue:'jobDesc', optionText:'JOB 설명'},
                                {optionValue:'useCd', optionText:'사용 여부' , optionCommonCode:"CMM00001" }                                
                                
                            ],onChange: function(selectedObject, value){
                            	
    							if(!gfnIsNull(selectedObject.optionAll) && selectedObject.optionAll == true){
									axdom("#" + mySearchRight.getItemId("searchTxt")).attr("readonly", "readonly");	
									axdom("#" + mySearchRight.getItemId("searchTxt")).val('');	
								}else{
									axdom("#" + mySearchRight.getItemId("searchTxt")).removeAttr("readonly");
								}
								
								
								if(!gfnIsNull(selectedObject.optionCommonCode)){
									gfnCommonSetting(mySearchRight,selectedObject.optionCommonCode,"searchCd","searchTxt");
								}else{
									
									axdom("#" + mySearchRight.getItemId("searchTxt")).show();
									axdom("#" + mySearchRight.getItemId("searchCd")).hide();
								}
    						},

						},
						{label:"", labelWidth:"", type:"inputText", width:"120", key:"searchTxt", addClass:"secondItem sendBtn", valueBoxStyle:"padding-left:0px;", value:"",
							onkeyup:function(e){
								if(e.keyCode == '13' ){
									axdom("#" + mySearchRight.getItemId("btn_search_jenkins")).click();
								}
							} 
						},
						{label:"", labelWidth:"", type:"selectBox", width:"100", key:"searchCd", addClass:"selectBox", valueBoxStyle:"padding-left:0px;", value:"01",
							options:[]
						},
						
						
						{label:"<i class='fas fa-list-ol'></i>&nbsp;목록 수&nbsp;", labelWidth:"60", type:"selectBox", width:"", key:"pageSize", addClass:"", valueBoxStyle:"", value:"30",
							options:[
							         	{optionValue:15, optionText:"15"},
		                                {optionValue:30, optionText:"30"},
		                                {optionValue:50, optionText:"50"},
		                                {optionValue:100, optionText:"100"},
		                                {optionValue:300, optionText:"300"},
		                                {optionValue:600, optionText:"600"},
		                                {optionValue:1000, optionText:"1000"},
		                                {optionValue:5000, optionText:"5000"},
		                                {optionValue:10000, optionText:"10000"},
		                                
		                            ],onChange: function(selectedObject, value){
		                            	var item = leftGrid.getList('selected')[0];
										if(gfnIsNull(item)){
											toast.push('좌측 목록에서 JENKINS를 선택해주세요.');
											return;
										}
										
										
							            fnInRightGridListSet(0,mySearchRight.getParam()+"&jenId="+item.jenId);
		    						}
						},
						{label:"<i class='fas fa-arrows-alt-v'></i>&nbsp;목록 높이&nbsp;", labelWidth:"60", type:"selectBox", width:"", key:"gridHeight", addClass:"", valueBoxStyle:"", value:"600",
							options:[
							         	{optionValue:300, optionText:"300px"},
		                                {optionValue:600, optionText:"600px"},
		                                {optionValue:1000, optionText:"1000px"},
		                                {optionValue:1200, optionText:"1200px"},
		                                {optionValue:2000, optionText:"2000px"},
		                                
		                            ],onChange: function(selectedObject, value){
		                            	rightGrid.setHeight(value);
		    						}
						},
						{label:"", labelWidth:"", type:"button", width:"80",style:"float:right;", key:"btn_search_jenkins_connect",valueBoxStyle:"padding:5px;", value:"<span>전체 접속확인</span>",
       							onclick:function(){
       								
       								var gridLen = rightGrid.getList().length;
       								
       								
       								if(gridLen > 0){
       									
										var gridJobInfo = rightGrid.getList()[0];
										var jenId = gridJobInfo.jenId;
										var jobId = gridJobInfo.jobId;
       									
       									fnSelectStm3000JobConfirmConnect("all",jenId, jobId, 0);
       								}else{
       									toast.push("JOB이 존재하지 않습니다.");
       								}
                    	}}
					]},
					{display:true, addClass:"", style:"", list:[
                    						
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_print_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-print' aria-hidden='true'></i>&nbsp;<span>프린트</span>",
							onclick:function(){
								$(rightGrid.exportExcel()).printThis({importCSS: false,importStyle: false,loadCSS: "/css/common/printThis.css"});
						}},
						{label:"", labelWidth:"", type:"button", width:"55",style:"float:right;", key:"btn_excel_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-file-excel' aria-hidden='true'></i>&nbsp;<span>엑셀</span>",
							onclick:function(){
								rightGrid.exportExcel("JENKINS-JOB_LIST.xls");
						}},
						{label : "",labelWidth : "",type : "button",width : "55",key : "btn_delete_jenkins",style : "float:right;",valueBoxStyle : "padding:5px;",value : "<i class='fa fa-trash-alt' aria-hidden='true'></i>&nbsp;<span>삭제</span>",
							onclick : function() {
								var item = (!gfnIsNull(Object.keys(rightGrid.focusedColumn)))? rightGrid.list[rightGrid.focusedColumn[Object.keys(rightGrid.focusedColumn)].doindex]:null;
								if(gfnIsNull(item)){
									toast.push('삭제 할 목록을 선택하세요.');
									return;
								}
								jConfirm("JOB을 삭제하시겠습니까?</br>연관된 모든 정보가 함께 삭제됩니다.", "알림창", function( result ) {
									if( result ){
										fnDeleteStm3000JobInfo(item.jenId,item.jobId);
									}
								});
							}
						},
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_update_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-edit' aria-hidden='true'></i>&nbsp;<span>수정</span>",
							onclick:function(){
								var item = (!gfnIsNull(Object.keys(rightGrid.focusedColumn)))? rightGrid.list[rightGrid.focusedColumn[Object.keys(rightGrid.focusedColumn)].doindex]:null;
								if(gfnIsNull(item)){
									toast.push('수정 할 목록을 선택하세요.');
									return;
								}

								var data = {"popupGb": "update", "jenId": item.jenId, "jobId": item.jobId};
        	                	
								gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3002JobDetailView.do',data,"650","585",'scroll',false);
						}},
						{label:"", labelWidth:"", type:"button", width:"60",style:"float:right;", key:"btn_insert_jenkins",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-save' aria-hidden='true'></i>&nbsp;<span>등록</span>",
							onclick:function(){
								var item = leftGrid.getList('selected')[0];
								var data = {
									"popupGb": "insert",
									"selJenId": (!gfnIsNull(item))? item.jenId : null
								};
								gfnLayerPopupOpen('/stm/stm3000/stm3000/selectStm3002JobDetailView.do',data,"1000","540",'scroll',false);
						}},
						{label:"", labelWidth:"", type:"button", width:"55", key:"btn_search_jenkins",style:"float:right;",valueBoxStyle:"padding:5px;", value:"<i class='fa fa-list' aria-hidden='true'></i>&nbsp;<span>조회</span>",
							onclick:function(){
								var item = leftGrid.getList('selected')[0];
								if(gfnIsNull(item)){
									toast.push('좌측 목록에서 JENKINS를 선택해주세요.');
									return;
								}
								
								
					            fnInRightGridListSet(0,mySearchRight.getParam()+"&jenId="+item.jenId);
						}},
						{label:"", labelWidth:"", type:"button", width:"100",style:"float:right;", key:"btn_search_jenkins_connect",valueBoxStyle:"padding:5px;", value:"<i class='fas fa-angle-double-right' aria-hidden='true'></i>&nbsp;<span>선택 접속확인</span>",
       							onclick:function(){
       								var item = (!gfnIsNull(Object.keys(rightGrid.focusedColumn)))? rightGrid.list[rightGrid.focusedColumn[Object.keys(rightGrid.focusedColumn)].doindex]:null;
       								if(gfnIsNull(item)){
       									toast.push('확인 할 목록을 선택하세요.');
       									return;
       								}
       								fnSelectStm3000JobConfirmConnect("normal",item.jenId,item.jobId, rightGrid.focusedColumn[Object.keys(rightGrid.focusedColumn)].doindex );
                    	}}
                    	]
                  		},
				]
			});
		}
		
	};
	
	jQuery(document.body).ready(function(){
		
		fnObjSearch.pageStart();
		
		axdom("#" + mySearchRight.getItemId("searchTxt")).attr("readonly", "readonly");
		
		
		axdom("#" + mySearchRight.getItemId("searchCd")).hide();

		
		fnBtnAuthCheck(mySearchRight);
	});
}


function fnSelectStm3000ConfirmConnect(jenId,index){
	leftGrid.setValue(index, "result", "progress");
	
	
	var jenkinsConnAjaxObj = new gfnAjaxRequestAction(
			{"url":"<c:url value='/stm/stm3000/stm3000/selectStm3000ConfirmConnect.do'/>","loadingShow":false}
			,{ "jenId" : jenId });
	
	jenkinsConnAjaxObj.setFnSuccess(function(data){
		data = JSON.parse(data);
		if(data.MSG_CD=="JENKINS_OK"){
			leftGrid.setValue(index, "result", "success");
			toast.push("접속 상태 정상");
		}else{
			leftGrid.setValue(index, "result", "fail");
			toast.push(data.MSG_CD);
		}
		
	});
	
	
	jenkinsConnAjaxObj.setFnError(function(xhr, status, err){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
	});
	
	
	jenkinsConnAjaxObj.send();
} 


function fnSelectStm3000AllConfirmConnect(index){
	
	if(index == -1){
		return false;
	}
	
	if(index >= leftGrid.getList().length){
		return false;
	}
	
	leftGrid.setValue(index, "result", "progress");
	
	
	var gridJenkinsInfo = leftGrid.getList()[index];
	var jenId = gridJenkinsInfo.jenId;
	
	
	var jenkinsConnAjaxObj = new gfnAjaxRequestAction(
			{"url":"<c:url value='/stm/stm3000/stm3000/selectStm3000ConfirmConnect.do'/>","loadingShow":false}
			,{ "jenId" : jenId });
	
	jenkinsConnAjaxObj.setFnSuccess(function(data){
		data = JSON.parse(data);
		if(data.MSG_CD=="JENKINS_OK"){
			leftGrid.setValue(index, "result", "success");
			toast.push(gridJenkinsInfo.jenNm+": 접속 상태 정상");
		}else{
			leftGrid.setValue(index, "result", "fail");
			toast.push(gridJenkinsInfo.jenNm+": "+data.MSG_CD);
			
		}
		
		fnSelectStm3000AllConfirmConnect(++index);
	});
	
	
	jenkinsConnAjaxObj.setFnError(function(xhr, status, err){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
	});
	
	
	jenkinsConnAjaxObj.send();
}


function fnSelectStm3000JobConfirmConnect(type,jenId, jobId, index){
	
	if(type == "all"){
		
		if(index == -1){
			return false;
		}
	}
	
	rightGrid.setValue(index, "result", "progress");
	
	
	var gridJobInfo = rightGrid.getList()[index];
	
	var jenkinsConnAjaxObj = new gfnAjaxRequestAction(
			{"url":"<c:url value='/stm/stm3000/stm3000/selectStm3000JobConfirmConnect.do'/>","loadingShow":false}
			,{ "jenId" : jenId, "jobId" : jobId });
	
	jenkinsConnAjaxObj.setFnSuccess(function(data){
		data = JSON.parse(data);
		if(data.MSG_CD=="JENKINS_OK"){
			rightGrid.setValue(index, "result", "success");
			toast.push(gridJobInfo.jobId+": 접속 상태 정상");
		}else{
			rightGrid.setValue(index, "result", "fail");
			toast.push(gridJobInfo.jobId+": "+data.MSG_CD);
		}
		if(type == "all"){
			
			if((++index) >= rightGrid.getList().length){
				return false;
			}
			
			
			var inGridJobInfo = rightGrid.getList()[index];
			var jenId = inGridJobInfo.jenId;
			var jobId = inGridJobInfo.jobId;
			
			
			fnSelectStm3000JobConfirmConnect("all",jenId, jobId,index);
		}
		
	});
	
	
	jenkinsConnAjaxObj.setFnError(function(xhr, status, err){
		data = JSON.parse(data);
		jAlert(data.message, "알림창");
	});
	
	
	jenkinsConnAjaxObj.send();
}


function fnStm3000GuideShow(){
	var mainObj = $(".main_contents");
	
	
	if(mainObj.length == 0){
		return false;
	}
	
	var guideBoxInfo = globals_guideContents["stm3000"];
	gfnGuideBoxDraw(true,mainObj,guideBoxInfo);
}
</script>


<div class="main_contents" style="height: auto;">
	<form:form commandName="jen1000VO" id="searchFrm" name="searchFrm" method="post" onsubmit="return false;">
		
	</form:form>
	<div class="stm3000_title"><c:out value="${sessionScope.selMenuNm }"/></div>
	<div class = "tab_contents menu" > <!-- class="main_frame" -->
		<div class="frame_contents left">
			<div class="sub_title">
				JENKINS 관리
			</div>
			<div id="AXSearchTarget_left" guide="stm3000JenkinsBtn"></div><br>
			<div class="dpl_wrap white">
				<input type="hidden" name="strInSql" id="strInSql" />
				<div data-ax5grid="grid_left" data-ax5grid-config="{}" style="height: 600px;" guide="stm3000JenkinsList"></div>	
			</div>
		</div>
		<div class="frame_contents right">
			<div class="sub_title">
				JOB 관리
			</div>
			<div id="AXSearchTarget_right" guide="stm3000JobBtn"></div><br>
			<div class="dpl_wrap white">
				<div data-ax5grid="grid_right" data-ax5grid-config="{}" style="height: 600px;" guide="stm3000JobList"></div>	
			</div>
		</div>
	</div>
</div>
		
<jsp:include page="/WEB-INF/jsp/lunaops/bottom/footer.jsp" />