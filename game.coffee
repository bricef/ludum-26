
root = exports ? this

class root.Scene
  constructor: (elem, config) ->
    @haikus = config.shots
    @basepic = config.base
    @start = config.start
    @end = config.end
    @elem = $(elem)
    @render()
    $('<div id="haiku">'+@start+'</div>').appendTo(@elem)
    $("#haiku").delay(3000).fadeOut(4000).queue(() -> @say)
      
    
    
 
  render: () ->
    @elem.html("")
    $('<img />').attr({id: "base", src: @basepic}).appendTo(@elem)
    if @haikus.length
      for haiku in @haikus
        $('<img />').attr({src: haiku.img})
          .css("left", haiku.offset.x)
          .css("top", haiku.offset.y)
          .appendTo(@elem)
  
  say: () ->
    if @haikus.length
      $('<div id="haiku">'+@haikus[0].haiku+'</div>').appendTo(@elem)
      $("#haiku").fadeOut(4000)
    else
      $('<div id="haiku">'+@end+'</div>').hide().appendTo(@elem)
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

  next: (elem, coord) ->
    if @inhaiku(coord, @haikus[0])
      @haikus = @haikus.slice(1)
    @render(elem)
    @say()



class root.Story
  constructor: (@element) ->
    @scenes = []

  addScene: (scene) ->
    @scenes.push scene

  next: (coord) ->
    @scenes[0].next(@element)
 
  
