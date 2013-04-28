
root = exports ? this

class root.Scene
  constructor: (elem, config) ->
    @haikus = config.shots
    @basepic = config.base
    @start = config.start
    @end = config.end
    @elem = $(elem)
    @render
    $('<div id="haiku">'+@start+'</div>').appendTo(@elem)
    $('<div id="images" />').appendTo(@elem)
    $("#haiku").delay(2000).fadeOut 3000, =>
      if @haikus.length
        $("#haiku").html(@haikus[0].haiku).fadeIn 2000, =>
          do @render
          $("#haiku").delay(2000).fadeOut(2000)
      
    
    
 
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
    if @haikus.length
      $("#haiku").hide().html(@haikus[0].haiku).appendTo(@elem)
      $("#haiku").fadeIn(2000).delay(2000).fadeOut(2000)
    else
      $("#haiku").hide().html(@end).appendTo(@elem)
      $("#haiku").fadeIn(3000)
    
  
  inhaiku: (coord, haiku) ->
    console.log coord
    console.log haiku
    inhaiku = haiku.offset.x < coord.x \
    and coord.x < (haiku.offset.x+haiku.size.x) \
    and haiku.offset.y < coord.y \
    and coord.y < (haiku.offset.y+haiku.size.y)
    
    console.log inhaiku
    inhaiku

  next: (coord) ->
    if @inhaiku(coord, @haikus[0])
      @haikus = @haikus.slice(1)
    @render()
    @say()



class root.Story
  constructor: (@element) ->
    @scenes = []

  addScene: (scene) ->
    @scenes.push scene

  next: (coord) ->
    @scenes[0].next(@element)
 
  
