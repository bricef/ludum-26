
root = exports ? this

class root.Scene
  constructor: (elem, config) ->
    @haikus = config.shots
    @basepic = config.base
    @start = config.start
    @end = config.end
    @elem = $(elem)
    @click = false
    @render
    $('<div id="haiku"><p>'+@start+'</p></div>').appendTo(@elem)
    $('<div id="images" />').appendTo(@elem)
    $("#haiku").delay(2000).fadeOut 3000, =>
      if @haikus.length
        $("#haiku").html("<p>"+@haikus[0].haiku+"</p>").fadeIn 2000, =>
          do @render
          $("#haiku").delay(4000).fadeOut 2000, =>
            @click = true
      
  render: () ->
    images = $("#images")
    images.empty()
    $('<img />').attr({id: "base", src: @basepic, class:"disp"}).appendTo(images)
    if @haikus.length
      for haiku in @haikus
        $('<img />').attr({src: haiku.img, class:"disp"})
          .css("left", haiku.offset.x)
          .css("top", haiku.offset.y)
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
    
  
  inhaiku: (coord, haiku) ->
    console.log coord
    console.log haiku
    inhaiku = haiku.offset.x < coord.x \
    and coord.x < (haiku.offset.x+haiku.size.x) \
    and haiku.offset.y < coord.y \
    and coord.y < (haiku.offset.y+haiku.size.y)
    inhaiku

  next: (coord) ->
    if @click
      if @inhaiku(coord, @haikus[0])
        @haikus = @haikus.slice(1)
      @render()
      @say()

  
