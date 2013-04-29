
root = exports ? this

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
    $("#haiku").html('<p class="cbox">'+@start+'</p>').delay(2000).fadeOut 3000, =>
      $("#haiku").html('<p class="cbox">'+@verses[0].verse+"</p>").fadeIn 2000, =>
          do @render
          $("#haiku").delay(4000).fadeOut 2000, =>
            @clickOn()

  finish: () ->
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
    $("#haiku").hide().html('<p class="cbox">'+end+'</p><img src="'+pic+'" />').fadeIn(3000)
  
  showText: (msg, callback) ->
    # TODO: Should accept multiple messages and display 
    # them one after the other with a blank background in between.
    @clickOff()
    $("#haiku").hide().html('<p class="cbox">'+msg+"</p>").fadeIn(500).delay(3000).fadeOut 2000 , =>
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
    screen.fadeIn(500).delay(3000).delay(2000).delay(500).delay(3000).fadeOut(2000)
    haiku.html('<p class="cbox">'+feedback+"</p>").fadeIn(500).delay(3000).fadeOut 2000, =>
      haiku.html('<p class="cbox">'+newverse+"</p>").fadeIn(500).delay(3000).fadeOut 2000, =>
        @clickOn()
        if callback
          callback()


  next: (coord) ->
    verse = @verses[0]
    if @click
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
              @finish()

#            @showText(verse.items[item.id].feedback, () =>
#              # when feedback is shown, remove the verse
#              @verses = @verses.slice(1)
#              # show the next verse!
#              if @verses.length
#                @showText(@verses[0].verse)
#              else
#                @finish()
#            )
          else
            @showText("I wasn't ready to cut this out of my life just yet...")

  
