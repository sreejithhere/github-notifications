# A single Comment view
class app.Views.Comment extends Backbone.View
  template: JST['app/templates/comment.us']
  className: 'conversation-comment'

  keyboardEvents:
    'space': 'toggle'

  events:
    'click .conversation-meta': 'toggle'
    'focusin': 'select'
    'focusout': 'unselect'

  # Initialize the view
  #
  # Required options:
  # notification - the notification for this conversation
  initialize: (options) ->
    @notification = options.notification
    @listenTo @model, 'selected', @selected
    @listenTo @model, 'unselected', @unselected

  render: =>
    @$el.html @template(@model.toJSON())
    @$el.addClass if @unread() then 'expanded' else 'collapsed'
    @$el.attr('tabindex', 0) # Make it focusable
    app.trigger 'render', @
    @

  # Returns true if comment was created since the notification was last read
  unread: ->
    last_read_at = @notification.get('last_read_at')
    !last_read_at || moment(last_read_at) < moment(@model.get('created_at'))

  # Toggle the expanded or collapsed state of the comment
  toggle: (e) ->
    e.preventDefault()
    @$el.toggleClass('collapsed expanded')

  # Select this comment
  select: ->
    @model.collection.select @model

  # Unselect this comment
  unselect: ->
    @model.collection.select null

  # This comment was selected
  selected: ->
    @bindKeyboardEvents()
    @$el.addClass('selected')
    @$el.scrollIntoView(20)

  # This comment was unselected
  unselected: ->
    @unbindKeyboardEvents()
    @$el.removeClass('selected')

  # Only bind keyboard events if model is selected
  bindKeyboardEvents: ->
    super if @model.isSelected()
