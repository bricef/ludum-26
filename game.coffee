
root = exports ? this

class root.Scene
  constructor: (elem, config) ->
    @verses = config.verses
    @items = config.items
    
    @basepic = config.base
    
    @start = config.start
    @end = config.end
    @elem = $(elem)
   
    @score = 0
    
    @max_score = @items.length * 1
    @min_score = @items.length * -1

    @click = false
    $('<div id="images" />').appendTo(@elem)
    $('<div id="haiku"></div>').appendTo(@elem)
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
    $("#haiku").html('<p>'+@start+'</p>').delay(2000).fadeOut 3000, =>
      $("#haiku").html("<p>"+@verses[0].verse+"</p>").fadeIn 2000, =>
          do @render
          $("#haiku").delay(4000).fadeOut 2000, =>
            @clickOn()

  finish: () ->
    # TODO: sort out endings based on score here.
    $("#haiku").hide().html("<p>"+@end+"</p>").fadeIn(3000)
  
  showText: (msg, callback) ->
    # TODO: Should accept multiple messages and display 
    # them one after the other with a blank background in between.
    @clickOff()
    $("#haiku").hide().html("<p>"+msg+"</p>").fadeIn(500).delay(3000).fadeOut 2000 , =>
      @clickOn()
      if callback
        callback()

  
  initem: (coord, item) ->
    initem = item.offset.x < coord.x \
    and coord.x < (item.offset.x+item.size.x) \
    and item.offset.y < coord.y \
    and coord.y < (item.offset.y+item.size.y)
    initem

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
            @showText(verse.items[item.id].feedback, () =>
              # when feedback is shown, remove the verse
              @verses = @verses.slice(1)
              # show the next verse!
              if @verses.length
                @showText(@verses[0].verse)
              else
                @finish()
            )
          else
            @showText("I wasn't ready to cut this out of my life just yet...")

  
