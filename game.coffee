
root = exports ? this

DEBUG = false

if not DEBUG
  fadein_delay = 500
  fadeout_delay = 2000
  wait_delay = 2000
else
  fadein_delay = 500
  fadeout_delay = 500
  wait_delay = 500


class root.Scene
  constructor: (elem, config) ->
    @verses = config.verses
    @items = config.items
    
    @basepic = config.base
    
    @start = config.start
    @end = config.end
    @endings = config.endings
    @elem = $(elem)
    @credits = config.credits
   
    @score = 0
    
    @max_score = 7
    @min_score = -7

    @click = false
    $('<div id="images" />').appendTo(@elem)
    $('<div id="bscreen" />').appendTo(@elem)
    $('<div id="haiku"></div>').appendTo(@elem)
    $("#bscreen").hide()
    @begin()
    
    @elem.click (event) =>
      os = @elem.offset()
      coords = {x:event.pageX-os.left, y:event.pageY-os.top}
      @next(coords)
      null
      
  clickOn: () ->
    @click = true

  clickOff: () ->
    @click = false

  render: () ->
    images = $("#images")
    images.empty()
    $('<img />').attr({id: "base", src: @basepic, class:"disp"}).appendTo(images)
    if @items.length
      for item in @items
        $('<img />').attr({src: item.img, class:"disp"})
          .css("left", item.offset.x)
          .css("top", item.offset.y)
          .appendTo(images)
  
  begin: () ->
    $("#haiku").html('<p class="cbox">'+@start+'</p>').delay(wait_delay).fadeOut fadeout_delay, =>
      $("#haiku").html('<p class="cbox">'+@verses[0].verse+"</p>").fadeIn fadein_delay, =>
        $("#bscreen").show().delay(wait_delay).fadeOut(fadeout_delay)
        do @render
        $("#haiku").delay(wait_delay).fadeOut fadeout_delay, =>
          @clickOn()

  getEnding: () ->
    # this could probably be cleaner, but whatever
    if @score == 0 # neutral
      @endings[2]
    else if @score < -3 #terrible
      @endings[4]
    else if @score < 0 #bad
      @endings[3]
    else if @score > 3 #great
      @endings[0]
    else if @score > 0 #good
      @endings[1]
  
  finish_click_callback: (event, bed) ->
    os = @elem.offset()
    coords = {x:event.pageX-os.left, y:event.pageY-os.top}
    if @click and @initem(coords, bed)
      @clickOff()
      console.log "clicked on bed!!"
      # remove bed from pictures, add ending picture to picture stack, remove handcuffs
      @items = (item for item in @items when (item.id isnt bed.id) and (item.id isnt "handcuffs") )
      console.log @items
      do @render
      ending = @getEnding()
      $('<img />').attr({src: ending.img, class:"disp" ,id:"finalimg"})
          .css("left", ending.offset.x)
          .css("top", ending.offset.y)
          .appendTo(images)
          # grow item to fil page
          .delay(1000)
          .animate({width:"60%", top:"50px"}, 1000).animate({opacity:0.3},1000)
      $('#bscreen').delay(1000).fadeIn(1000)
      # fade in final verse
      $('#haiku').delay(1000).html('<p class="cbox">'+ending.text+'</p>').delay(1000).fadeIn(1000).delay(3000).fadeOut 1000, =>
        $("#haiku").html('<p class="cbox credits">'+@credits+'</p>').fadeIn(1000)
      # delay 
      # show credits
    else
      @showText(@end.verse)

  finish: (feedback) ->
    @clickOff()
    console.log "FINISH: ", feedback
    screen = $("#bscreen")
    haiku = $("#haiku")
    # start by displaying the feedback from the last verse
    screen.fadeIn(fadein_delay).delay(wait_delay).delay(fadeout_delay).delay(fadein_delay).delay(wait_delay).fadeOut(fadeout_delay)
    haiku.html('<p class="cbox">'+feedback+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
      haiku.html('<p class="cbox">'+@end.verse+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
        # Now we nuke the event handler on #main and replace it with the terminal handler 
        # yes, I know how ugly this is. Shut up.
        @elem.unbind()
        bed = (item for item in @items when item.id is @end.item)[0]
        @elem.click (event) =>
          @finish_click_callback(event, bed)
        @clickOn()

  
  showText: (msg, callback) ->
    # TODO: Should accept multiple messages and display 
    # them one after the other with a blank background in between.
    @clickOff()
    $("#bscreen").fadeIn(fadein_delay).delay(wait_delay).fadeOut(fadeout_delay)
    $("#haiku").hide().html('<p class="cbox">'+msg+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay , =>
      @clickOn()
      if callback
        callback()

  
  initem: (coord, item) ->
    initem = item.offset.x < coord.x \
    and coord.x < (item.offset.x+item.size.x) \
    and item.offset.y < coord.y \
    and coord.y < (item.offset.y+item.size.y)
    initem

  showTexts: (feedback, newverse, callback) ->
    screen = $("#bscreen")
    haiku = $("#haiku")
    @clickOff()
    screen.fadeIn(fadein_delay).delay(wait_delay).delay(fadeout_delay).delay(fadein_delay).delay(wait_delay).fadeOut(fadeout_delay)
    haiku.html('<p class="cbox">'+feedback+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
      haiku.html('<p class="cbox">'+newverse+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
        @clickOn()
        if callback
          callback()


  next: (coord) ->
    verse = @verses[0]
    if @click
      @clickOff()
      for item in @items.slice(0).reverse()
        if @initem(coord, item)
          if verse.items[item.id]
            # update score
            @score = @score + verse.items[item.id].score
            # remove item from item list
            @items = @items.filter (it) -> it.id isnt item.id
            # re-render the scene with the new item list
            @render()
            # show feedback
            
            if @verses.length >1
              @showTexts verse.items[item.id].feedback, @verses[1].verse, () =>
                @verses = @verses.slice(1)
            else
              @finish(verse.items[item.id].feedback)

          else
            @showText("I'm not ready to cut this out of my life just yet...")

  
