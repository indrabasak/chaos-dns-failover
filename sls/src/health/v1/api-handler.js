/**
 * A AWS Lambda for fetching health.
 *
 * @author Indra Basak <indra.basak@autodesk.com>
 * @since Jun 13, 2023
 */
const logger = require('../../common/lambda-logger');

// eslint-disable-next-line no-unused-vars
exports.getHealth = async (req, res) => {
  logger.info('Calling health endpoint');
  const payload = {
    status: 'UP',
    region: process.env.AWS_REGION
  }

  return { status: 200, payload: payload};
};
