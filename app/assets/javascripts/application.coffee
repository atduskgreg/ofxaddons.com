# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery.cookie
#= require jquery.lazy
#= require jquery.timeago
#= require bootstrap-sprockets

$ ->
  $("img.lazy").lazy()
  $("abbr.timeago").timeago()
  $('[data-toggle="tooltip"]').tooltip()

  # due to page caching, we have to dynamically change the
  # login/logout links based on js
  # if($.cookie('user_id')) {
  #   $(".navbar-nav .login").hide();
  #   $(".navbar-nav .logout").show();
  # }

  $(".js-categorize").click (e) ->
    $("#categorize_modal").modal("show")

  $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    # handle things on the admin repos page
    if $("body").prop("id") == "admin_repos_index"
      switch data.controller
        when "admin/repos"
          if data.action == "update"
            debugger
            $(e.currentTarget).closest("tr")
              .find(".repo-type .label")
              .text(data.repo.type_title)
              .removeClass("invisible")
