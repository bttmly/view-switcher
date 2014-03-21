# View Switcher

Little jQuery plugin to make view transitions more pleasant. Currently uses callbacks to sequence functions. Will support option to sequence functions with by actual time.

```javascript
var options = {
  views : // anything jQuery() can understand
  container : // anything jQuery() can understand
  attrIdentifier : // HTML attribute used to identify views; defaults to 'id'
  initialView : // anything jQuery() can understand
  timedOffsets : // set to true if using set delay times rather than callbacks
  useHistory : // NOT IMPLEMENTED YET.use History API for pushstate & popstate.

  exit :    // function( outgoingView, prepare ) {}
            // handles the exit of the outgoing view; "this" bound to container
  prepare : // function( outgoingView, incomingView, enter ) {}
            // handles preparing the container
  enter :   // function( incomingView, enter ) {}
            // handles the entrance of the incoming view; "this" bound to container

  exitDelay : // Number. Delay in ms before calling exit()
  prepareDelay : // Number. Delay in ms between calling exit() and prepare()
  enterDelay : // Number. Delay in ms between calling prepare() and enter()
}
```