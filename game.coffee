
root = exports ? this

class root.Scene
  constructor: (elem, config) ->
    @verses = config.verses
    @items = config.items
    
    @basepic = config.base
    
    @start = config.start
    @end = config.end
    @elem = $(elem)
    
    @click = false
    $('<div id="images" />').appendTo(@elem)
    $('<div id="haiku"><p>'+@start+'</p></div>').appendTo(@elem).delay(2000).fadeOut 3000, =>
      $("#haiku").html("<p>"+@verses[0].verse+"</p>").fadeIn 2000, =>
          do @render
          $("#haiku").delay(4000).fadeOut 2000, =>
            @click = true
      
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
  
  say: () ->
    @click = false
    if @haikus.length
      $("#haiku").hide().html("<p>"+@haikus[0].haiku+"</p>").appendTo(@elem)
      $("#haiku").fadeIn(2000).delay(4000).fadeOut 2000, =>
        @click = true
    else
      $("#haiku").hide().html("<p>"+@end+"</p>").appendTo(@elem)
      $("#haiku").fadeIn 3000, =>
        @click = true
    
  
  initem: (coord, item) ->
    initem = item.offset.x < coord.x \
    and coord.x < (item.offset.x+item.size.x) \
    and item.offset.y < coord.y \
    and coord.y < (item.offset.y+item.size.y)
    initem

  next: (coord) ->
    if @click
      for item in @items
        if @initem(coord, item)
          @items = @items.slice(1)
      @render()
      @say()

  
