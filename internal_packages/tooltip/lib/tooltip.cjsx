_ = require 'underscore-plus'
React = require 'react/addons'

###
The Tooltip component displays a consistent hovering tooltip for use when
extra context information is required.

It's a global-level singleton
###

module.exports =
Tooltip = React.createClass

  getInitialState: ->
    top: 0
    left: 0
    width: 0
    pointerLeft: 0
    display: false
    content: ""

  componentWillMount: ->
    @CONTENT_PADDING = 15
    @DEFAULT_DELAY = 750
    @KEEP_DELAY = 500
    @_showDelay = @DEFAULT_DELAY
    @_showTimeout = null
    @_showDelayTimeout = null

  componentWillUnmount: ->
    clearTimeout @_showTimeout
    clearTimeout @_showDelayTimeout

  render: ->
    <div className="tooltip-wrap" style={@_positionStyles()}>
      <div className="tooltip-content">{@state.content}</div>
      <div className="tooltip-pointer" style={left: @state.pointerLeft}></div>
    </div>

  _positionStyles: ->
    top: @state.top
    left: @state.left
    width: @state.width
    display: if @state.display then "block" else "none"

  # This are public methods so they can be bound to the window event
  # listeners.
  onMouseOver: (e) ->
    target = @_elementWithTooltip(e.target)
    if target then @_onTooltipEnter(target)
    else if @state.display then @_hideTooltip()

  onMouseOut: (e) ->
    if @_elementWithTooltip(e.fromElement) and not @_elementWithTooltip(e.toElement)
      @_onTooltipLeave()

  _elementWithTooltip: (target) ->
    while target
      break if target?.dataset?.tooltip?
      target = target.parentNode
    return target

  _onTooltipEnter: (target) ->
    @_enteredTooltip = true
    clearTimeout(@_showTimeout)
    clearTimeout(@_showDelayTimeout)
    @_showTimeout = setTimeout =>
      @_showTooltip(target)
    , @_showDelay

  _onTooltipLeave: ->
    return unless @_enteredTooltip
    @_enteredTooltip = false
    clearTimeout(@_showTimeout)
    @_hideTooltip()

    @_showDelay = 10
    clearTimeout(@_showDelayTimeout)
    @_showDelayTimeout = setTimeout =>
      @_showDelay = @DEFAULT_DELAY
    , @KEEP_DELAY

  _showTooltip: (target) ->
    return unless @isMounted()
    content = target.dataset.tooltip
    guessedWidth = @_guessWidth(content)
    dim = target.getBoundingClientRect()
    top = dim.top + dim.height + 11
    left = dim.left + dim.width / 2
    @setState
      top: top
      left: @_tooltipLeft(left, guessedWidth)
      width: guessedWidth
      pointerLeft: @_tooltipPointerLeft(left, guessedWidth)
      display: true
      content: target.dataset.tooltip

  _guessWidth: (content) ->
    # roughly 11px per character
    guessWidth = content.length * 11
    return Math.max(Math.min(guessWidth, 250), 50)

  _tooltipLeft: (targetLeft, guessedWidth) ->
    max = @_windowWidth() - guessedWidth - @CONTENT_PADDING
    left = Math.min(Math.max(targetLeft - guessedWidth/2, @CONTENT_PADDING), max)
    return left

  _tooltipPointerLeft: (targetLeft, guessedWidth) ->
    POINTER_WIDTH = 6 + 2 #2px of border-radius
    max = @_windowWidth() - @CONTENT_PADDING
    min = @CONTENT_PADDING
    absoluteLeft = Math.max(Math.min(targetLeft, max), min)
    relativeLeft = absoluteLeft - @_tooltipLeft(targetLeft, guessedWidth)

    left = Math.max(Math.min(relativeLeft, guessedWidth-POINTER_WIDTH), POINTER_WIDTH)
    return left

  _windowWidth: ->
    document.getElementsByTagName('body')[0].getBoundingClientRect().width

  _hideTooltip: ->
    return unless @isMounted()
    @setState
      top: 0
      left: 0
      width: 0
      pointerLeft: 0
      display: false
      content: ""
