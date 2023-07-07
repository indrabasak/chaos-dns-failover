/**
 * A helper class to run fault experiments.
 *
 * @author Indra Basak
 * @since Jun 15, 2023
 */

const {
  FisClient,
  CreateExperimentTemplateCommand,
  StartExperimentCommand,
  StopExperimentCommand,
  DeleteExperimentTemplateCommand
  // eslint-disable-next-line import/no-extraneous-dependencies
} = require('@aws-sdk/client-fis');
const { TemplateBuilder } = require('./template-builder');

class ExperimentHelper {
  constructor(endpoint, region) {
    this.endpoint = endpoint;
    this.region = region;

    this.client = new FisClient({
      endpoint: this.endpoint,
      region: this.region,
      credentials: {
        accessKeyId: 'test',
        secretAccessKey: 'test'
      }
    });
  }

  async startExperiment(service) {
    try {
      const params = TemplateBuilder.createTemplate(this.region, service);
      const command = new CreateExperimentTemplateCommand(params);
      const data = await this.client.send(command);
      this.experimentTemplateId = data.experimentTemplate.id;
      console.log(data);

      const startCmd = new StartExperimentCommand({
        experimentTemplateId: this.experimentTemplateId
      });
      const startResponse = await this.client.send(startCmd);
      console.debug(startResponse);
      this.experimentId = startResponse.experiment.id;
    } catch (e) {
      console.debug(e);
      throw new Error('Failed to create experiment');
    }
  }

  async stopExperiment() {
    if (this.experimentId) {
      try {
        const stopCmd = new StopExperimentCommand({ id: this.experimentId });
        const stopRsp = await this.client.send(stopCmd);
        console.log(stopRsp);
      } catch (e) {
        console.debug(e);
      }
    }

    if (this.experimentTemplateId) {
      try {
        const deleteCmd = new DeleteExperimentTemplateCommand({
          id: this.experimentTemplateId
        });
        const deleteRsp = await this.client.send(deleteCmd);
        console.log(deleteRsp);
      } catch (e) {
        console.debug(e);
      }
    }
  }
}

module.exports = { ExperimentHelper };
