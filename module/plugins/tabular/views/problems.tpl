%import time
%now = time.time()
%helper = app.helper
%datamgr = app.datamgr

%top_right_banner_state = datamgr.get_overall_state()

<script type="text/javascript">
  var page = '{{page}}';
  var cols = {{cols}};
  var tab_nb_elts = {{tab_nb_elts}};
</script>


%# Look for actions if we must show them or not
%global_disabled = ''
%if app.manage_acl and not helper.can_action(user):
%global_disabled = 'disabled-link'
<script type="text/javascript">
  var actions_enabled = false;
</script>
%else:
<script type="text/javascript">
  var actions_enabled = true;
</script>
%end

%if toolbar=='hide':
<script type="text/javascript">
  var toolbar_hide = true;
</script>
%else:
<script type="text/javascript">
  var toolbar_hide = false;
</script>
%end



<script type="text/javascript">
  function submitform()
  {
  document.forms["search_form"].submit();
  }

  /* Catch the key ENTER and launch the form
  Will be link in the password field
  */
  function submitenter(myfield,e){
  var keycode;
  if (window.event) keycode = window.event.keyCode;
  else if (e) keycode = e.which;
  else return true;


  if (keycode == 13){
  submitform();
  return false;
  }else
  return true;
  }

  $('.typeahead').typeahead({
  // note that "value" is the default setting for the property option
  /*source: [{value: 'Charlie'}, {value: 'Gudbergur'}, {value: 'Charlie2'}],*/
  source: function (typeahead, query) {
  $.ajax({url: "/lookup/"+query,
  success: function (data){
  typeahead.process(data)}
  });
  },
  onselect: function(obj) {
  $("ul.typeahead.dropdown-menu").find('li.active').data(obj);
  }
  });


  var active_filters = [];

  // List of the bookmarks
  var bookmarks = [];
  var bookmarksro = [];

  // Ok not the best way to restrict the admin functions to admin, but I can't find another way around.
  %if user.is_admin:
  var advfct=1;
  %else:
  var advfct=0;
  %end

  %for b in bookmarks:
  declare_bookmark("{{!b['name']}}","{{!b['uri']}}");
  %end
  %for b in bookmarksro:
  declare_bookmarksro("{{!b['name']}}","{{!b['uri']}}");
  %end

</script>


<script type="text/javascript">
  // We will create here our new filter options
  // This should be outside the "pageslide" div. I don't know why
  new_filters = [];
  current_filters = [];
</script>
<div id="pageslide" style="display:none">
  <div class='row'>
    <span class='span8'><h2>Filtering options</h2></span>
    <span class='span3 pull-right'><a class='btn btn-danger' href="javascript:$.pageslide.close()"><i class="icon-remove"></i> Close</a></span>
  </div>
  <div class='in_panel_filter'>
    <h3>Names</h3>
    <form name='namefilter' class='form-horizontal'>
      <input name='name'></input>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_name_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <h3>Hostgroup</h3>
    <form name='hgfilter' class='form-horizontal'>
      <select name='hg'>
	%for hg in datamgr.get_hostgroups_sorted():
	<option value='{{hg.get_name()}}'> {{hg.get_name()}} ({{len(hg.members)}})</option>
	%end
      </select>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_hg_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <h3>Tag</h3>
    <form name='htagfilter' class='form-horizontal'>
      <select name='htag'>
	%for (t, n) in datamgr.get_host_tags_sorted():
	<option value='{{t}}'> {{t}} ({{n}})</option>
	%end
      </select>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_htag_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <h3>Realms</h3>
    <form name='realmfilter' class='form-horizontal'>
      <select name='realm'>
	%for r in datamgr.get_realms():
	<option value='{{r}}'> {{r}}</option>
	%end
      </select>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_realm_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <h3>States</h3>
    <form name='ack_filter' class='form-horizontal'>

      <span class="help-inline">Ack </span>
      %if page=='problems':
      <input type='checkbox' name='show_ack'></input>
      %else:
      <input type='checkbox' name='show_ack' checked></input>
      %end

      <span class="help-inline">Both ack states</span>
      <input type='checkbox' name='show_both_ack'></input>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_state_ack_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <form name='downtime_filter' class='form-horizontal'>
      <span class="help-inline">Downtime</span>
      %if page=='problems':
      <input type='checkbox' name='show_downtime'></input>
      %else:
      <input type='checkbox' name='show_downtime' checked></input>
      %end
      <span class="help-inline">Both downtime states</span>
      <input type='checkbox' name='show_both_downtime'></input>
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_state_downtime_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <form name='criticity_filter' class='form-horizontal'>
      <span class="help-inline">Critical Only</span>
      %if page=='problems':
      <input type='checkbox' name='show_critical'></input>
      %else:
      <input type='checkbox' name='show_critical' checked></input>
      %end
      <p class='pull-right'><a class='btn btn-success pull-right' href="javascript:save_state_criticity_filter();"> <i class="icon-chevron-right"></i> Add</a></p>
    </form>

    <span><p>&nbsp;</p></span>


  </div>
  <div class='row'>
    <span class='pull-left'><a id='remove_all_filters' class='btn btn-inverse' href="javascript:clean_new_search();"> <i class="icon-remove"></i> Remove all filters</a></span>
    <span class='pull-right'><a id='launch_the_search' class='btn btn-warning' href="javascript:launch_new_search('/{{page}}');"> <i class="icon-play"></i> Launch the search!</a></span>
    <span><p>&nbsp;</p></span>
  </div>
  <div id='new_search'>
  </div>

  <!-- We put a final touch at the filters and buttons of this panel -->
  <script>refresh_new_search_div();</script>

</div>

<script >$(function(){
  $(".slidelink").pageslide({ direction: "right", modal: true});
  // When the user ask for the panel, he don't want to refresh now
  $(".slidelink").click(function() {reinit_refresh();});
  });

  $(function(){
  // We prevent the drpdown to close when we go on a form into it.
  $('.form_in_dropdown').on('click', function (e) {
  e.stopPropagation()
  });
  });

</script>

<div class="span12 nomargin" id='filters_panel_cont' style="min-height:0px;margin-bottom: 10px!important;border: 2px solid gray;padding:5px;">
  <div class="span12 nomargin" id='filters_panel'>
    <div style='opacity:0.6;position:relative;right:0px;top:0px;float:right;' class=''><a href="javascript:close_filters_panel();"><i class="icon-remove"></i></a></div>
    <div class="span10 nomargin">
      %include tabular_filters globals()      
    </div>
  </div>
</div>


<div class="span12 nomargin">
  <div id='toolbar' class='span2 gray-back top-box-gray' style='position:relative;'>
    <img src="/static/eltdetail/images/corner-bottom-right.png" style="position:absolute;right:0%;bottom:0%;">
    <div id='global_bookmarks'>
      <h3>Quick search</h3>
      <ul class="unstyled">
	
      %for e in quick_searches:
      <li><i class="icon-tag"></i><a href="{{e['path']}}">{{e['display']}}</a></li>
      %end
      </ul>
    </div>
    <div id='bookmarks'></div>
    <script>
      $(function(){
      refresh_bookmarks();
      });</script>

  </div>


  <!-- Start of the Right panel, with all problems -->
  <div class="span10 no-leftmargin">

    <div class='span12'>
      <!-- Keep to make the span2 NOt the first-->
      <div></div>
      <div class='span7'>
	<a id='select_all_btn' style="display:inline;" href="javascript:select_all_problems()" data-toggle="tooltip" data-placement="bottom" data-original-title="Select all" class="btn btn_hide_when_selection applytooltip"><i class="icon-check"></i></a>
	<a id='unselect_all_btn' data-toggle="tooltip" data-placement="bottom" data-original-title="Unselect all"  style="display:inline;" href="javascript:unselect_all_problems()" class="btn btn_show_when_selection applytooltip"><i class="icon-minus"></i></a>
	<div class="btn-group">
	  <a href='javascript:toggle_filters_panel();' style="display:inline;" class='btn applytooltip' data-toggle="tooltip" data-placement="bottom" data-original-title="Filter" id='filters_panel_btn'>filter</a>
	  <a id='save_new_bookmark_btn' style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Save as Bookmark" class="btn applytooltip" href='javascript:save_new_bookmark();'> <i class="icon-star"></i></a>
	  </div>
	<div class="btn-group">
	  <a style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Options" class="btn applytooltip" href="javascript:toggle_table_options();"><i id='btn-options' class="icon-cog"></i></a>
	</div>
	<div class="btn-group">
	  <a style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Refresh" class="btn btn_hide_when_selection applytooltip" href='javascript:force_refresh();'> <i class="icon-refresh"></i></a>
	</div>
	
	<div class="btn-group btn_show_when_selection" >
	  <a class="btn applytooltip" style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Try to fix" href="javascript:try_to_fix_all();"><i class="icon-pencil icon-white"></i></a>
	  <a class="btn applytooltip" style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Recheck now" href="javascript:recheck_now_all()"><i class="icon-repeat icon-white"></i></a>
	  <a class="btn applytooltip" style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Submit OK result" href="javascript:submit_check_ok_all()"><i class="icon-share-alt icon-white"></i></a>
	  <a class="btn applytooltip" style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Acknoledge" href="javascript:acknowledge_all('{{user.get_name()}}')"><i class="icon-ok icon-white"></i></a>
	  <a class="btn applytooltip" style="display:inline;" data-toggle="tooltip" data-placement="bottom" data-original-title="Remove forever" href="javascript:remove_all('{{user.get_name()}}')"><i class="icon-remove icon-white"></i></a>
	</div>

	
      </div>
      <div class='span4'>
	%include pagination_element navi=navi, app=app, page=page, div_class="center no-margin"
      </div>
    </div>
    


    <div id="accordion" class="span12">

      %# " We remember the last hname so see if we print or not the host for a 2nd service"
      %last_hname = ''

      %# " We try to make only importants things shown on same output "
      %last_output = ''
      %nb_same_output = 0
      %if app.datamgr.get_nb_problems() > 0 and page == 'problems' and app.play_sound:
      <EMBED src="/static/sound/alert.wav" autostart=true loop=false volume=100 hidden=true>
	%end

	%# Main table
	<table class='table-striped table-bordered table-hover pull-left tabular_table span12'>
	  <thead style='background-color: #3d3d3d;'>
	    <tr>
	      <th>

	      </th>
	      <th></th>
	      <th>
		Host
              </th>
	      <th>
		Service
              </th>
	      <th class='th-state'>State</th>
	      <th class='th-business-impact'>Priority</th>
	      <th class='th-state-type'>State type</th>
	      <th class='th-last-check'>Last Check</th>
	      <th class='th-realm'>Realm</th>
	      <th class='th-attempts'>Attempts</th>
	      <th class='th-duration'>Duration</th>
	      <th class='th-output'>Output</th>
	      
	    </tr>
	  </thead>
	  <tbody>

	  %for pb in pbs:
	  
	%# " We check for the same output and the same host. If we got more than 3 of same, make them opacity effect"
	%if pb.output == last_output and pb.host_name == last_hname:
        %nb_same_output += 1
	%else:
        %nb_same_output = 0
	%end
	%last_output = pb.output

	%if nb_same_output > 2 and page == 'problems':
	<tr class='hide hide_for_{{last_hname}} element' id='{{helper.get_html_id(pb)}}' data-raw-obj-name='{{pb.get_full_name()}}'>
	%else:
        <tr class='element' id='{{helper.get_html_id(pb)}}' data-raw-obj-name='{{pb.get_full_name()}}'>
	%end
	<td class='tick' style="cursor:pointer;" onmouseover="hovering_selection('{{helper.get_html_id(pb)}}')" onclick="add_remove_elements('{{helper.get_html_id(pb)}}')">
	  <div>
	    <img id='selector-{{helper.get_html_id(pb)}}' class='img_tick' src='/static/images/tick.png' />
	  </di>
	</td>
	<td class='img_status'>
	  <img style="position:absolute;" width="20px;" height="20px;" src="{{helper.get_icon_state(pb)}}" />
	  <div class="aroundpulse">
	    %# " We put a 'pulse' around the elements if it's an important one "
	    %if pb.business_impact > 2 and pb.state_id in [1, 2, 3]:
	    <span class="pulse"></span>
	    %end
	  </div>

	</td>
	<td class="hostname cut_long">
	%if pb.host_name == last_hname:
          &nbsp;
	%else:
	  %graphs = [{'img_src':'/graph-panel/?hname='+pb.host_name+'&sdesc=__HOST__'}]
	  %onmouse_code = ''
	  %if len(graphs) > 0:
	  %onmouse_code = 'onmouseover="display_hover_img(\'%s\',\'{{pb.host_name}}\',\'\');" onmouseout="hide_hover_img();" ' % graphs[0]['img_src']
	  %onmouse_code = 'onclick="toggle_hover_img(\'%s\',\'%s\',\'\');" ' % (graphs[0]['img_src'], pb.host_name)
	  %end
	  <img class="pull-right perfometer" {{!onmouse_code}} src='/static/tabular/img/performance.png'/>
	  {{!helper.get_host_link(pb)}}
	%end
	</td>
	%last_hname = pb.host_name
	
	<td class="srvdescription cut_long">
	%if pb.__class__.my_type == 'service':

	  %graphs = [{'img_src':'/graph-panel/?hname='+pb.host_name+'&sdesc='+pb.service_description}]
	  %onmouse_code = ''
	  %if len(graphs) > 0:
	   %onmouse_code = 'onclick="toggle_hover_img(\'%s\',\'%s\',\'%s\');" ' % (graphs[0]['img_src'], pb.host_name, pb.service_description)
	%end
	<img class="pull-right perfometer" {{!onmouse_code}} src='/static/tabular/img/performance.png'/>	
	{{!helper.get_link(pb, short=True)}}
	%else:
          &nbsp;
        %end
	</td>
	<td class='txt_status state_{{pb.state.lower()}} td-state'> 
	  {{pb.state}}
	</td>
	<td class='txt_business-impact td-business-impact'>
	  %for j in range(0, pb.business_impact-2):
	  <img src='/static/images/star.png' alt="star">
	  %end
        </td>
	<td class='txt_state-type td-state-type'>
          {{pb.state_type}}
        </td>
	<td class='txt_last-check td-last-check' rel="tooltip" data-original-title='{{helper.print_date(pb.last_chk)}}'>
	  {{helper.print_duration(pb.last_chk, just_duration=True, x_elts=2)}}
        </td>

	 <td class='txt_realm td-realm'>
          {{pb.get_realm()}}
        </td>
	 <td class='txt_realm td-attempts'>
           {{pb.attempt}}/{{pb.max_check_attempts}}
        </td>
	 
        <td class='duration td-duration' rel="tooltip" data-original-title='{{helper.print_date(pb.last_state_change)}}'>
	  {{helper.print_duration(pb.last_state_change, just_duration=True, x_elts=2)}}
	</td>
	%# "We put a title (so a tip) on the output onlly if need"
	<td class='output td-output' rel="tooltip" data-original-title="{{pb.output}}">
	  {{!helper.print_output(app, pb.output)}}
	</td>
	<!--<td class="no_border opacity_hover shortdesc expand" style="max-width:20px;" onclick="show_detail('{{helper.get_html_id(pb)}}')">
	  <i class="icon-chevron-down" id='show-detail-{{helper.get_html_id(pb)}}'></i> <i class="icon-chevron-up chevron-up" id='hide-detail-{{helper.get_html_id(pb)}}'></i>
	</td>-->

	</tr>

	<!--
	%if nb_same_output == 2 and page == 'problems':
	<tr class="tableCriticity opacity_hover">
	  <a rel=tooltip title='Expand the same service problems' href="javascript:show_hidden_problems('hide_for_{{last_hname}}');" id='btn-hide_for_{{last_hname}}' class='go-center'>
	    <i class="icon-arrow-down"></i>
	    <i class="icon-arrow-down"></i>
	    <i class="icon-arrow-down"></i>
	  </a>
	</tr>
	%end
	
	%# "This div is need so the element will came back in the center of the previous div"
	<tr id="{{helper.get_html_id(pb)}}" data-raw-obj-name='{{pb.get_full_name()}}' class="detail row-fluid">
	  <td collspan=5>
	    %if len(pb.impacts) > 0:
	      <hr />
	      <h5>Impacts:</h5>
	    %end
	    %for i in helper.get_impacts_sorted(pb):
	      <div>
		<p>
		  <img style="width: 16px; height: 16px;" src="{{helper.get_icon_state(i)}}" />
		  <span class="alert-small alert-{{i.state.lower()}}">{{i.state}}</span> for {{!helper.get_link(i)}}
		  %for j in range(0, i.business_impact-2):
		  <img src='/static/images/star.png' alt="star">
		  %end
		</p>
	      </div>
	    %end
	  <td>
	</tr>
	-->
	
	%end
	
	  </tbody>
</table>
	  


</div>
%include pagination_element navi=navi, app=app, page=page, div_class="center"

</div>

%# """ This div is an image container and will move hover the perfometer with mouse hovering """
<div id="img_hover" class='degraded-back'>
  <!--<div id='spinner_graph'></div>-->
</div>


<div id="save_search_div" class='hide well' style="position:absolute;">
  <a id="save_search_close_btn" href='javascript:close_save_bookmark();'><i class="icon-remove"></i></a>
  <form id='save_search_form' name='save_search_form' class='form-horizontal'>
	 <input type="text" id="save_filter_name" placeholder="Filter name"/>
	 <a class="btn" href="javascript:do_save_new_bookmark();">Save</a>
  </form>
</div>


%include table_options_div

%rebase layout globals(), title='All problems', top_right_banner_state=top_right_banner_state, js=['tabular/js/img_hovering.js', 'tabular/js/accordion.js', 'tabular/js/sliding_navigation.js', 'tabular/js/filters.js', 'tabular/js/filters2.js', 'tabular/js/bookmarks.js'], css=['tabular/css/table_view.css', 'tabular/css/pagenavi.css', 'tabular/css/perfometer.css', 'tabular/css/img_hovering.css', 'tabular/css/sliding_navigation.css', 'tabular/css/filters.css', 'tabular/css/accordion.css'], refresh=True, menu_part='/'+page, user=user