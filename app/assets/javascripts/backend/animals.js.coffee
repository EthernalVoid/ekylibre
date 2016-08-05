#= require bootstrap/modal

((G, $) ->

  $(document).ajaxSend (e, xhr, options) ->
    token = $('meta[name=\'csrf-token\']').attr('content')
    xhr.setRequestHeader 'X-CSRF-Token', token
    return


  class golumn
    constructor: (id) ->
      @id = id

      @selectedItemsIndex = {}

      @newContainerModal =
        show: ko.observable false
        group: ko.observable false
        targetContainer: ko.observable undefined


      @moveAnimalsModal =
        show: ko.observable false
        container: ko.observable false
        animals: ko.observableArray []
        started_at: ko.observable ''
        stopped_at: ko.observable ''
        worker: ko.observable undefined
        variant: ko.observable undefined
        production_support: ko.observable undefined
        group: ko.observable undefined
        alert: ko.observable false
        checkNature: ko.observable false

      @moveAnimalsModal.checkNature.subscribe (value) =>
        if value != 1
          @moveAnimalsModal.variant undefined

      @showAnimalDetailsModal = ko.observable false
      @showNewGroupModal = ko.observable false

      @animalDetailsModalOptions = ko.observable false

      @newGroupModalOptions =
        group: ko.observable ''
        variantId: ko.observable ''


      @cancelAnimalDetails = () =>
        @animalDetailsModalOptions false
        @showAnimalDetailsModal false

      @cancelNewGroup = () =>
        @showNewGroupModal false

      @addContainer = =>
        # Lets JQuery to do this simple task, no need an observable for that.
        name = $("#containers_list").val()
        id = $("input[name='containers_list']").val()
        console.log 'CHANGE THIS', @newContainerModal.targetContainer()

        group = @newContainerModal.group()
        newContainer = new G.Container(id, name, ko.observableArray([]), group)
        group.containers.push newContainer

        @resetNewContainerModal()
        @toggleMoveAnimalModal(newContainer)

#      @containers_list = ko.observableArray []
      @workers_list = ko.observableArray []
      @natures_list = ko.observableArray []
      @production_support_list = ko.observableArray []


      @groups = ko.observableArray []
      @containers = ko.observableArray []
      @animals = ko.observableArray []


      @drop = ko.observable
      @hoverdrop = ko.observable

      @enableDropZones = (state = false) =>
        ko.utils.arrayForEach @groups(), (group) =>
          group.droppable state
          ko.utils.arrayForEach group.containers(), (container) =>
            container.droppable state

      @toggleAnimalDetailsModal = (animal) =>
        @animalDetailsModalOptions animal
        @showAnimalDetailsModal true
        return

      @toggleNewGroupModal = () =>
        @showNewGroupModal true
        return

      @toggleNewContainerModal = (group) =>
        @newContainerModal.show(true)
        @newContainerModal.group(group)
        #Be sure only one modal is displayed
        @moveAnimalsModal.show(false)

      @toggleMoveAnimalModal = (container) =>
        @moveAnimalsModal.container(container)


        for id, item of @selectedItemsIndex
          @moveAnimalsModal.animals.push item


        @moveAnimalsModal.show(true)

        $.ajax '/backend/animals/load_workers',
          type: 'GET',
          dataType: 'JSON',
          success: (json_data) ->
            ko.utils.arrayForEach json_data, (j) =>
              window.app.workers_list.push j
            return true

        $.ajax '/backend/animals/load_natures',
          type: 'GET',
          dataType: 'JSON',
          success: (json_data) ->
            ko.utils.arrayForEach json_data, (j) =>
              window.app.natures_list.push j
            return true

        $.ajax '/backend/animals/load_production_supports',
          type: 'GET',
          dataType: 'JSON',
          data: {group_id: group.id},
          success: (json_data) ->
            ko.utils.arrayForEach json_data, (j) =>
              window.app.production_support_list.push j
            return true

      @moveAnimals = () =>

        animals_id = ko.utils.arrayMap @moveAnimalModalOptions.animals(), (a) =>
          return a.id

#        if animals_id.length > 0 and @moveAnimalModalOptions.container() != undefined and @moveAnimalModalOptions.group() != undefined and @moveAnimalModalOptions.worker() != undefined and @moveAnimalModalOptions.started_at() != '' and @moveAnimalModalOptions.stopped_at() != '' and @moveAnimalModalOptions.production_support() != undefined
        if animals_id.length > 0 and @moveAnimalModalOptions.container() != undefined and @moveAnimalModalOptions.group() != undefined and @moveAnimalModalOptions.worker() != undefined and @moveAnimalModalOptions.started_at() != '' and @moveAnimalModalOptions.stopped_at() != ''

          data =
            animals_id: animals_id.join(',')
            container_id: @moveAnimalModalOptions.container().id
            worker_id: @moveAnimalModalOptions.worker().id
            started_at: @moveAnimalModalOptions.started_at()
            stopped_at: @moveAnimalModalOptions.stopped_at()

          if @moveAnimalModalOptions.group().id != @moveAnimalModalOptions.animals()[0].group_id()
            data['group_id'] = @moveAnimalModalOptions.group().id

          if @moveAnimalModalOptions.variant()
             data['variant_id'] =  @moveAnimalModalOptions.variant().id

          if @moveAnimalModalOptions.production_support()
            data['production_support_id'] = @moveAnimalModalOptions.production_support().id

          $.ajax '/backend/animals/change',
            type: 'PUT',
  #          type: 'GET',
            dataType: 'JSON',
            data: data,
            success: (res) =>
              @showMoveAnimalModal false

              # maj
              ko.utils.arrayForEach @moveAnimalModalOptions.animals(), (a) =>
                 id = a.id
                 name = a.name
                 img = a.img
                 status = a.status
                 sex = a.sex
                 num = a.number_id
                 @animals.remove a
                 @animals.push new golumn.Animal(id, name, img, status, sex, num, @moveAnimalModalOptions.container().id, @moveAnimalModalOptions.group().id)


              @resetMoveAnimalsModal()


              return true

            error: (res) =>
              @showMoveAnimalModal false
              alert res.statusText
              @cancelAnimalsMoving()
              return false
        else
          @moveAnimalModalOptions.alert true

      @resetMoveAnimalsModal = () =>

        @moveAnimalsModal.show false
        @moveAnimalsModal.container false
        @moveAnimalsModal.animals.removeAll()
        @moveAnimalsModal.started_at ''
        @moveAnimalsModal.stopped_at ''
        @moveAnimalsModal.worker undefined
        @moveAnimalsModal.variant undefined
        @moveAnimalsModal.production_support undefined
        @moveAnimalsModal.group undefined
        @moveAnimalsModal.alert false
        @moveAnimalsModal.checkNature false


      @resetNewContainerModal = () =>
        @newContainerModal.show false
        @newContainerModal.group false
#        @newContainer = ko.observable false
#        @containerModalOptions = ko.observable false
#        @containers_list.removeAll()
#        @showNewContainerModal false
#        @droppedAnimals.removeAll()


      @resetSelectedItems = () =>
        for id, item  of @selectedItemsIndex
          item.checked(false)

        @selectedItemsIndex = {}


      @updatePreferences = () =>

        data = []

        ko.utils.arrayForEach @groups(), (g) =>
          group = {id: g.id, containers: []}
          curContainers = ko.utils.arrayFilter @containers(), (c) =>
            c.group_id() == g.id

          containers = ko.utils.arrayMap curContainers, (c) =>
            {id: c.id, position: c.position()}

          containers = containers.sort (a,b)->
            if a.position > b.position
              return 1
            else
              return -1

          ko.utils.arrayForEach containers, (item) ->
            group.containers.push item.id
          data.push group

        $.ajax
          url: "/backend/golumns/#{@id}"
          type: 'PATCH'
          data:
            positions: data

      @showAddGroup = (item) =>
        return item() == @groups().length-1

      @addGroup = () =>
        if group = @newGroupModalOptions.group

          $.ajax '/backend/animals/add_group',
            type: 'PUT',
#            type: 'GET',
            dataType: 'JSON',
            data: {name:group(),variant_id: @newGroupModalOptions.variantId()},
            success: (res) =>
              if res.id
                @groups.push new golumn.Group(res.id, res.name)

              @showNewGroupModal false
              return true

            error: (res) =>
              @showNewGroupModal false
              return false


  @loadData = (golumn, element) =>
    $.ajax '/backend/animals/load_animals',
      type: 'GET'
      dataType: 'JSON'
      data:
        golumn_id: golumn
      beforeSend: () ->
        element.addClass("loading")
        return
      complete: () ->
        element.removeClass("loading")
        return
      success: (json_data) ->
        groups = ko.utils.arrayMap json_data, (group) =>

          places = ko.utils.arrayMap group.places, (place) =>

            animals = ko.utils.arrayMap place.animals, (animal) =>
              new G.Item(animal.id, animal.name, animal.picture_path, animal.status, animal.sex_text, animal.identification_number, place)

            new G.Container(place.id, place.name, ko.observableArray(animals), group)

          new G.Group(group.id, group.name, ko.observableArray(places))

        window.app.groups = ko.observableArray(groups)

        ko.applyBindings window.app

        return true

      error: (data) ->
        return false

    return


  $(document).ready ->
    # $("*[data-golumns]").mousewheel (event, delta) ->
    #   if $(this).prop("wheelable") != "false"
    #     @scrollLeft -= (delta * 30)
    #     event.preventDefault()


    $("*[data-golumns='animal']").each ->
      golumn_id = $(this).data("golumns")
      window.app = new golumn(golumn_id)
      window.loadData(golumn_id, $(this))

) golumn, jQuery
