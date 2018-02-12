###
# @class SlideshowComponent
# @brief Renders markdown into slides with support for bullets and custom classes.
#
# We can specify custom styles for components anywhere
# by having the first non-whitespace text of a component be of the format (.styleName)
#
# If you need to have strings like this in your slides,
# then put some whitespace in the pattern,
# or use '﹒' or '．' (unicode periods, not equivalent to '.')
#
# By default, styles on the h1 slide title get raised to the slide as a whole.
# This makes it convenient to have styles like (.small) for large blocks of code.
###
class SlideshowComponent
  constructor: () ->
    @root = $('.slides')

    @slides = []
    @currentSlide = 0

    #    A slide can have bullet points that show up
    #    one at a time by nesting them inside a bullet point
    #    with content "(delayed)". For example,
    #
    #    - (delayed)
    #    - this point will be hidden initially
    #    - this point will show up after the previous one
    #
    #    This variable maps the slide number to an array
    #    of html for each bullet point.
    @bullets = {}

    # if there are bullets, used to keep track of which one is showing
    @currentBullet = 0

  #   # optional listener for slide change events
  #   # called back with the number of the current slide
  #   # currently only used for updating the slide # in the footer
  #   @slideChange = null
  #
  # leave: (slide) ->
  #   @slides[slide].hide()
  #
  # enter: (slide) ->
  #   @slides[slide].show()

  _bulletsOnCurrentSlide: () ->
    # if we don't have any bullets stored for the slide
    # we treat that slide like a single-bullet slide
    if @bullets[@currentSlide] && @bullets[@currentSlide].length > 0
      return @bullets[@currentSlide].length
    else
      return 1

  _prevSlide: () =>
    if @currentBullet > 0 and @currentBullet < @_bulletsOnCurrentSlide()
      @currentBullet--
    else if @currentSlide > 0
      @leave(@currentSlide)
      @currentSlide--
      @currentBullet = @_bulletsOnCurrentSlide() - 1

    @_setCurrentSlide @currentSlide, @currentBullet

  _nextSlide: () =>
    if @currentBullet < @_bulletsOnCurrentSlide() - 1
      @currentBullet++
    else if @currentSlide + 1 < @slides.length
      @leave(@currentSlide)
      @currentSlide++
      @currentBullet = 0

    @_setCurrentSlide @currentSlide, @currentBullet

  _getLocationHash: ->
    return "#slide-#{@currentSlide}.#{@currentBullet}"

  _setCurrentSlide: (slide, bullet, force = false) ->
    return if window.location.hash is @_getLocationHash() && !force

    @currentSlide = slide
    @currentBullet = bullet

    if @bullets[@currentSlide]?
      for j in [0...@bullets[@currentSlide].length]
        if j <= @currentBullet
          @bullets[@currentSlide][j].show()
        else
          @bullets[@currentSlide][j].hide()

    @slideChange(@currentSlide) if @slideChange
    @enter(@currentSlide)
    history.pushState {}, '', @_getLocationHash()

  # we can specify that a list should be incrementally displayed via the markdown
  # - (delayed)
  #
  # If you want a literal expression that matches this,
  # just stick a space after the opening parenthesis
  _findBullets: () ->
    @_findBulletsForSlide($slide, idx) for $slide, idx in @slides

  _findBulletsForSlide: ($slide, idx) ->
    $slide.find('li').filter(() ->
      txt = $($(this).contents()[0]).text().trim()
      return txt.match /\(delayed\)/
    ).each (i, li) =>
      txtNode = $(li).contents()[0]
      txtNode.data = txtNode.data.replace("(delayed)", "")
      $(li).addClass 'delayed'

    $slide.find('.delayed li').each (i, li) =>
      @bullets[idx] = [] unless @bullets.hasOwnProperty idx
      @bullets[idx].push $(li)

  _attachStyles: () ->
    @_attachStylesToSlide($slide) for $slide in @slides

  _attachStylesToSlide: ($slide) ->
    $slide.find('*').each (idx, el) =>
      txtNode = $(el).contents()[0]
      return unless txtNode && txtNode.data

      # only trim once at the beginning,
      # so if you need the text (.red),
      # then you can do something like (.null) (.red)
      txtNode.data = txtNode.data.trimLeft()
      stylesRegex = /^\(\.([^\. \)]+)\)+/

      while (match = stylesRegex.exec(txtNode.data))
        if $(el).prop('tagName') == 'H1'
          $slide.addClass(match[1])
        else
          $(el).addClass(match[1])
        txtNode.data = txtNode.data.replace(stylesRegex, '')



  _parseSlides: () ->
    # make our slides into legit block elements
    # so we can style them and animate them as such
    @root.find('h1').each (idx, slideTitle) =>
      slide = $(slideTitle).nextUntil("h1").addBack()
      $(slide).detach()
      newSlide = $('<div class="slide"></div>')
      newSlide.append($(slide))
      @slides.push(newSlide)

    @root.append($slide) for $slide in @slides
    $slide.hide() for $slide in @slides

  _addEventListeners: () ->
    $(document).on('keydown', (event) =>
      switch event.which
        when 37, 38 then @_prevSlide()
        when 39, 40 then @_nextSlide()
    )

    for $slide in @slides
      hammertime = new Hammer($slide[0])
      hammertime.on 'swipeleft', () => @_nextSlide()
      hammertime.on 'swiperight', () => @_prevSlide()

  onCreate: () ->
    @_parseSlides()
    @_findBullets()
    @_attachStyles()

    #@_addCustomClasses()
    #@_addCustomStyles()
    #@_hideControlElements()

    # Restore progression if possible
    hash = window.location.hash
    match = /\#?slide-(\d+)(?:\.(\d+))?/.exec(hash)
    if match
      slide = if match[1] then parseInt(match[1]) else 0
      bullet = if match[2] then parseInt(match[2]) else 0
    else
      slide = 0
      bullet = 0
    @_setCurrentSlide slide, bullet, true

    # add some window bindings so we can programmatically adjust our slides
    window.prevSlide = @_prevSlide
    window.nextSlide = @_nextSlide

    @_addEventListeners()
