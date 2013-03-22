{Dialog, Tutorial, Step} = zootorial

window.dialog = new Dialog
  content: 'This is just a dialog!'

# Note "next" can be a step, which will add a "Continue" button to the dialog,
# an object mapping events to the appropriate next step,
# or `false`, which will emphasize the instruction instead of changing steps.
# If "next" is undefined, the tutorial ends.

# finalStep = new Step
#   title: 'Congratulations!'
#   content: 'You\'ve completed the tutorial.'

# window.tutorial = new Tutorial
#   title: 'Example tutorial'
#   firstStep: new Step
#     header: 'Welcome'
#     content: 'This is a tutorial'
#     next: new Step
#       header: 'Choose your own adventure'
#       content: 'Now we can fork the tutorial based on what the user does.'
#       instruction: 'Click one of the interesting things.'
#       next:
#         'click .interesting.one': new Step
#           header: 'Awesome!'
#           content: 'You chose the first one, which is great.'
#           next: finalStep

#         'click .interesting:not(".one")': new Step
#           header: 'You chose... poorly.'
#           content: 'You should have clicked the first one.'
#           instruction: 'Click the first interesting thing.'
#           next:
#             'click .intereting.one': finalStep
#             'click .interesting:not(".one")': false

events = [
  'click-close-dialog', 'render-dialog', 'attach-dialog'
  'open-dialog', 'close-dialog', 'destroy-dialog'
  'start-tutorial', 'complete-tutorial', 'end-tutorial'
  'enter-tutorial-step', 'complete-tutorial-step', 'exit-tutorial-step'
]

for eventName in events then do (eventName) ->
  $(document).on eventName, (e, args...) ->
    console.log "#{eventName.toUpperCase()}:", args...
