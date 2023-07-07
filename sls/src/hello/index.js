// Require and init API router module
const app = require('lambda-api')();

// Add CORS Middleware
app.use((req, res, next) => {
  // Add default CORS headers for every request
  res.cors();

  // Call next to continue processing
  next();
});

// register routes
app.register(require('./v1/routes'), { prefix: '/v1/' });

// log out routes
app.routes(true);

module.exports.handler = (event, context, callback) => {
  context.callbackWaitsForEmptyEventLoop = false;

  // Run the request
  app.run(event, context, callback);
};
