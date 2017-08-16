
var util = require('util');

async function callAsyncFunc(obj, func) {
   return new Promise((resolve, reject) => {
    
    // callback for the function invoked
    var cb = (err, result) => {
      if (err) {
        console.error(`error executing function '${func}' with params: ${util.inspect(arguments)}: ${err.message}`);
        return reject(err);
      }
      
      console.log(`function '${func}' completed successfully with result: ${util.inspect(result)}`);
      return resolve({ result });
    };

    var params = Array.prototype.slice.call(arguments, 2);
    params.push(cb);

    return obj[func].apply(obj, params);
  });
}

async function sleep(timeSecs) {
  return new Promise(resolve => setTimeout(() => resolve(), timeSecs * 1000));
}

module.exports = {
  callAsyncFunc,
  sleep
}
