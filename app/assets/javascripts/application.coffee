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
  # due to page caching, we have to dynamically change the
  # login/logout links based on js
  if ($.cookie('login'))
    $("li.current-user").text($.cookie('login')).removeClass("hidden")
    $("li.admin, li.logout").removeClass("hidden")
    $("li.login").addClass("hidden")

  $("img.lazy").lazy()
  $("abbr.timeago").timeago()
  $('[data-toggle="tooltip"]').tooltip()

  #
  # Admin unsorted repos
  #

  # prompt for addons categorization
  $(".js-categorize").click (e) ->
    $form    = $("form#new_repo")
    url_base = $form.data("url-base")
    repo_id  = $(e.currentTarget).data("repo-id")

    # fix up the form properties so they look like you'd expect for editing a repo
    $form.prop("action", "#{ url_base }/#{ repo_id }")
    $form.removeClass("new_repo")
    $form.addClass("edit_repo")
    $("#repo_type").val("Addon")

    # uncheck everything
    $form.find(".check_boxes").prop("checked", false)

    $("#repo_id").val(repo_id)
    $("#categorize_modal").modal("show")
    false

  #
  # handle AJAX responses
  #

  $("a[data-remote], form[data-remote]").on "ajax:error", (e, data, status, xhr) ->
    errors = ""
    for error in data.responseJSON.error
      errors += error + "\n"
    alert(errors)


  $("a[data-remote], form[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    # handle things on the admin repos page
    if $("body").prop("id") == "admin_repos_index"
      switch data.controller
        when "admin/repos"
          if data.action == "update"
            repo_id = data.repo.id
            $("#tr_repo_id_#{ repo_id }")
              .find(".repo-type .label")
              .text(data.repo.type_title)
              .removeClass("invisible")
            $("#categorize_modal").modal("hide")
