#= require application

# These must be loaded in specific order:
#= require jquery.dataTables.js
#= require dataTables.bootstrap.js

$ ->
  #
  # Admin unsorted repos
  #

  $(".js-data-table").DataTable({
    "pageLength": 50
  })

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
