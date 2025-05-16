import { defineCommand, log } from 'bunner/framework';
import { DockerComposeTool } from 'bunner/modules/docker';

export default defineCommand({
    command: 'dcd',
    description:
        'Stops and removes all running containers for this application',
    category: 'backend',
    action: async () => {
        const dc = await DockerComposeTool.create();
        await dc.downAll();
    },
});
