{Dialog, Tutorial, Step} = zootorial

window.dialog = new Dialog
  content: 'This is just a dialog!'

# Note "next" can be a step, which will add a "Continue" button to the dialog,
# an object mapping events to the appropriate next step,
# a function returning a step,
# or `false`, which will emphasize the instruction instead of changing steps.
# If "next" is undefined, the tutorial ends.

window.tutorial = new Tutorial
  id: 'example'
  firstStep: 'welcome'

  steps:
    length: 4
    welcome: new Step
      number: 1
      header: 'Welcome'
      details: 'This is a tutorial. Lorem ipsum dolor sit amet.'
      next: 'adventure'
      block: '.interesting'

    adventure: new Step
      number: 2
      attachment: 'left top .things left bottom'
      header: 'Choose your own adventure'
      details: 'Now we can fork the tutorial based on what the user does.'
      instruction: 'Click the first interesting thing.'
      actionable: '.interesting.one'
      focus: '.things'
      next:
        'click .interesting.one': 'awesome'
        'click .interesting:not(".one")': 'poor'

    awesome: new Step
      number: 3
      header: 'Awesome!'
      details: 'You chose the first one, which is great.'
      next: 'final'

    poor: new Step
      header: 'You chose... poorly.'
      details: 'You should have clicked the first one.'
      instruction: 'Click the <em>first</em> interesting thing.'
      actionable: '.interesting.one'
      next:
        'click .interesting.one': 'awesome'
        'click .interesting:not(".one")': false

    final: new Step
      number: 4
      title: 'Congratulations!'
      details: 'You\'ve completed the tutorial.'

window.tutorial.start()

events = [
  'click-close-dialog', 'render-dialog', 'attach-dialog'
  'open-dialog', 'close-dialog', 'destroy-dialog'
  'start-tutorial', 'complete-tutorial', 'end-tutorial'
  'enter-tutorial-step', 'complete-tutorial-step', 'exit-tutorial-step'
]

for eventName in events then do (eventName) ->
  $(document).on eventName, (e, args...) ->
    console.log "#{eventName.toUpperCase()}:", args...
