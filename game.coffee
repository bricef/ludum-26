
root = exports ? this

DEBUG = true

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
    @endings = config.endings
    @elem = $(elem)
   
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
    console.log "click on"
    @click = true

  clickOff: () ->
    console.log "click off"
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
          do @render
          $("#haiku").delay(wait_delay).fadeOut fadeout_delay, =>
            @clickOn()

  finish: (feedback) ->
    @clickOff()
    console.log "FEEDBACK: ", feedback
    screen = $("#bscreen")
    haiku = $("#haiku")
    # start by displaying the feedback from the last verse
    screen.fadeIn(fadein_delay).delay(wait_delay).delay(fadeout_delay).delay(fadein_delay).delay(wait_delay).fadeOut(fadeout_delay)
    haiku.html('<p class="cbox">'+feedback+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
      haiku.html('<p class="cbox">'+"TEST VERSE"+"</p>").fadeIn(fadein_delay).delay(wait_delay).fadeOut fadeout_delay, =>
        console.log ""
        @clickOn()

    # now the feedback has been shown begin the end sequence, with "I can't sleep here".
    
    # this could probably be cleaner, but whatever
    if @score == 0 # neutral
      end = @endings[2].text
      pic = @endings[2].img
    else if @score < -3 #terrible
      end = @endings[4].text
      pic = @endings[4].img
    else if @score < 0 #bad
      end = @endings[3].text
      pic = @endings[3].img
    else if @score > 3 #great
      end = @endings[0].text
      pic = @endings[0].img
    else if @score > 0 #good
      end = @endings[1].text
      pic = @endings[1].img
    #$("#haiku").hide().html('<p class="cbox">'+end+'</p><!--<img src="'+pic+'" />-->').fadeIn(3000)
  
  showText: (msg, callback) ->
    # TODO: Should accept multiple messages and display 
    # them one after the other with a blank background in between.
    @clickOff()
    $("#haiku").hide().html('<p class="cbox">'+msg+"</p>").fadeIn(500).delay(1000).fadeOut 1000 , =>
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
    console.log "show texts"
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
          console.log("coord found")
          console.log item.id, verse.items
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

  
