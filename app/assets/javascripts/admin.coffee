#= require application

# These must be loaded in specific order:
#= require jquery.dataTables.js
#= require dataTables.bootstrap.js

$ ->
  #
  # Admin unsorted repos
  #

  # prompt for addons categorization
  bindCategorizationModal = ->
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

  bindCategorizationModal()

  $(".js-data-table")
    # configure sortable/searchable tables
    .DataTable({ "pageLength": 50 })

    # re-bind the click events for categorization buttons when the table is redrawn
    .on 'draw.dt', ->
      bindCategorizationModal()
      colorCodeTypes()

  #
  # handle AJAX responses
  #

  $("a[data-remote], form[data-remote]").on "ajax:error", (e, data, status, xhr) ->
    errors = ""
    for error in data.responseJSON.error
      errors += error + "\n"
    alert(errors)

  colorCodeTypes = ->
    $("td.repo-type").each ->
      e = $(@)
      e.css("color", "white")
      switch e.data("type")
        when "addon"      then e.css("background-color", "#5cb85c")
        when "deleted"    then e.css("background-color", "#d9534f")
        when "incomplete" then e.css("background-color", "#f0ad4e")
        when "nonaddon"   then e.css("background-color", "#d9534f")
        else e.css("background-color", "#777")

  colorCodeTypes()

  $("a[data-remote], form[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    # handle things on the admin repos page
    if $("body").prop("id") == "admin_repos_index"
      switch data.controller
        when "admin/repos"
          if data.action == "update"
            repo_id = data.repo.id
            $("#tr_repo_id_#{ repo_id }")
              .find(".repo-type")
              .text(data.repo.type_title)
              .data("type", data.repo.type.toLowerCase())
            $("#categorize_modal").modal("hide")
            colorCodeTypes()
