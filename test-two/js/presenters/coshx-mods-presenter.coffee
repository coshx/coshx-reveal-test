class SlideshowPresenter
  constructor: () ->
    @header = $('.header')
    @slideshow = new SlideshowComponent()
#    @slideshow.slideChange = (slide) => $(".slide-number").text(slide)
#    @clock = $('.clock')
    $(document).ready () => @onCreate()

#  _setClock: () ->
#    current_date = new Date()
#    minutes = current_date.getMinutes().toString()
#    minutes = "0#{minutes}" if minutes.length == 1

#    hours = current_date.getHours().toString()
#    hours = "0#{hours}" if hours.length == 1

#    amPm = if current_date.getHours() >= 12 then 'pm' else 'am'
#    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
#    days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

    # content = "#{days[current_date.getDay()]} #{months[current_date.getMonth()]} #{current_date.getDate()}"
    # content += " #{current_date.getFullYear()} "
#    content = "#{hours}:#{minutes}#{amPm}"
#    @clock.text content

  _initHideAnswers: () ->
    $(".hideAnswers .answer").on "click", ->
      $(this).toggleClass("answer")

  onCreate: () ->
    @slideshow.onCreate()
    @_initHideAnswers()

#    unless @clock.hasClass('no-js')
#      @_setClock()
#      setInterval (() => @_setClock()), 60 * 1000
