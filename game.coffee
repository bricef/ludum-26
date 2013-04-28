
root = exports ? this

class root.Scene
  constructor: (config) ->
    @haikus = config.shots
    @basepic = config.base
    @start = config.start
    @end = config.end
  
  render: (element) ->
    $(element).html("")
    $('<img />').attr({id: "base", src: @basepic}).appendTo(element)
    if @haikus.length
      for haiku in @haikus
        $('<img />').attr({src: haiku.img})
          .css("top", haiku.offset.x)
          .css("left", haiku.offset.y)
          .appendTo(element)
      $('<div id="haiku">'+@haikus[0].haiku+'</div>').appendTo(element)
      $("#haiku").fadeOut(4000)
    else
      $('<div id="haiku">'+@end+'</div>').appendTo(element)
      $("#haiku").fadeIn(3000)
      
    
  
  inhaiku: (coord, haiku) ->
    haiku.offset.x < coord.x < (haiku.offset.x+haiku.size.x) \
    and haiku.offset.y < coord.y < (haiku.offset.y+haiku.size.y)

  next: (elem, coord) ->
    if @inhaiku(coord, @haikus[0])
      console.log "in haiku"
      @haikus = @haikus.slice(1)
      console.log @haikus
    @render(elem)



class root.Story
  constructor: (@element) ->
    @scenes = []

  addScene: (scene) ->
    @scenes.push scene

  next: (coord) ->
    @scenes[0].next(@element)
 
  
