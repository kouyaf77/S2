class Drawer
  constructor: (element_name, user_name, channel) ->
    @canvas_element_name = element_name
    @faye = window.fayeClient
    @channel = channel

    #explicit set canvas width and height
    slide_width = $("#current_slide").width()
    slide_height = $("#current_slide").height()
    
    @canvasWidth = $(element_name)[0].width = slide_width
    @canvasHeight = $(element_name)[0].height = slide_height
    
    @canvasCtx = $(element_name)[0].getContext("2d")
    @canvasCtx.fillStyle = "solid"
    @canvasCtx.strokeStyle = "#ECD018"
    @canvasCtx.lineWidth = 2
    @canvasCtx.lineCap = "round"

    @drawQueueTicker = 0
    @drawQueue = []
  
  binding: ->
    that = this
    $(@canvas_element_name).on 'drag dragstart dragend', (e) ->
      type = e.handleObj.type
      offset = $(this).offset()
    
      x = e.pageX - offset.left
      y = e.pageY - offset.top
      
      that.draw(x,y,type)
  
  makeMessagePayload: (queue) ->
    payload =
      messageType: 'draw'
      messageOwner: '' #temporally
      messageExtra:
        pointSet:
          "#{queue[0].x} #{queue[0].y} \
           #{queue[1].x} #{queue[1].y} \
           #{queue[2].x} #{queue[2].y} \
           #{queue[3].x} #{queue[3].y}"
           
    return payload

  publish: (message) ->
    @faye.publish(@channel, message) if @faye

  draw: (x, y, type) ->
    if type is "dragstart"
      @canvasCtx.beginPath()
      @canvasCtx.moveTo(x, y)
    else if type is "drag"
      if @drawQueueTicker < 4
        @drawQueue.push
          x: x / @canvasWidth
          y: y / @canvasHeight
        @drawQueueTicker += 1
      else
        message = @makeMessagePayload(@drawQueue)
        @publish(message)

        #reset ticker and queue
        @drawQueueTicker = 0
        @drawQueue = @drawQueue.slice 3


      @canvasCtx.lineTo(x, y)
      @canvasCtx.stroke()
    else
      @canvasCtx.closePath()

window.Drawer = Drawer
