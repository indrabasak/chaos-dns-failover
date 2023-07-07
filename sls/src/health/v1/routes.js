const apiHandler = require('./api-handler');

// routes
// eslint-disable-next-line no-unused-vars
module.exports = (app, opts) => {
  app.get('/health', (req, res) => {
    apiHandler
      .getHealth(req, res)
      .then((response) => {
        res.status(response.status).json(response.payload);
      })
      .catch((response) => {
        res.status(response.status).json(response.payload);
      });
  });
};
