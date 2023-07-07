/**
 * A AWS Lambda for saying hello.
 *
 * @author Indra Basak <indra.basak@autodesk.com>
 * @since Jun 14, 2023
 */
const logger = require('../../common/lambda-logger');

// eslint-disable-next-line no-unused-vars
exports.hello = async (req, res) => {
  logger.info('Calling hello endpoint');
  return { status: 200, payload: 'Hello, it\'s me, I was wondering if after all these years you\'d like to meet' };
};
