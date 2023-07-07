/**
 * A helper to build experiment templates.
 *
 * @author Indra Basak
 * @since Jun 15, 2023
 */

class TemplateBuilder {
  static createTemplate(regionName, serviceName) {
    return {
      actions: {
        'lambda all operation': {
          actionId: 'localstack:generic:api-error',
          parameters: {
            service: serviceName,
            percentage: '100',
            exception: `exception, error in ${serviceName}`,
            errorCode: '500',
            region: regionName
          }
        }
      },
      description: `terrible error in ${serviceName}`,
      stopConditions: [
        {
          source: 'none'
        }
      ],
      roleArn: 'arn:aws:iam:123456789012:role/ExperimentRole'
    };
  }
}

module.exports = { TemplateBuilder };
