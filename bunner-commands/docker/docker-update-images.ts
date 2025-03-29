import { $, spawn } from 'bun';
import { defineCommand, log } from '../../bunner/framework';

interface UpdateStats {
    updated: number;
    failed: number;
    skipped: number;
    alreadyLatest: number;
    total: number;
}

export default defineCommand({
    command: 'update-images',
    description: 'Updates all Docker images to their latest versions',
    options: [
        {
            short: 'f',
            long: 'force',
            type: 'boolean',
            description:
                'Force update all images without checking if they are outdated',
            required: false,
        },
        {
            short: 'q',
            long: 'quiet',
            type: 'boolean',
            description: 'Quiet mode - less verbose output',
            required: false,
        },
    ] as const,
    action: async ({ options }) => {
        const forceUpdate = options.force || false;
        const quietMode = options.quiet || false;

        try {
            // Get unique image repository:tag combinations excluding <none> tags
            const imageListResult =
                await $`docker image ls --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | sort -u`.text();
            const images = imageListResult
                .trim()
                .split('\n')
                .filter((img) => img.trim() !== '');

            if (images.length === 0) {
                log.info('No Docker images found on this system.');
                return 0;
            }

            if (!quietMode) {
                log.info(
                    `Checking ${images.length} Docker images for updates...`
                );
            }

            const stats: UpdateStats = {
                updated: 0,
                failed: 0,
                skipped: 0,
                alreadyLatest: 0,
                total: images.length,
            };

            // Process each image
            for (const img of images) {
                // Skip images without a valid repository
                if (img.includes('<none>')) {
                    stats.skipped++;
                    continue;
                }

                if (!quietMode) {
                    log.info(`Checking ${img}...`);
                }

                try {
                    // Get current digest
                    let currentDigest = '';
                    try {
                        currentDigest = (
                            await $`docker image inspect --format "{{index .RepoDigests 0}}" ${img}`.text()
                        ).trim();
                    } catch {
                        // If we can't get digest, we'll just proceed with the pull
                    }

                    // Force update or couldn't get digest, just pull
                    if (forceUpdate || !currentDigest) {
                        if (!quietMode) {
                            log.info(`Pulling ${img}...`);
                        }

                        try {
                            await $`docker pull ${img}`;
                            if (!quietMode) {
                                log.success(`✓ Updated ${img}`);
                            }
                            stats.updated++;
                        } catch (error) {
                            if (!quietMode) {
                                log.error(`✗ Failed to update ${img}`);
                            }
                            stats.failed++;
                        }
                        continue;
                    }

                    // Try to pull the image and check for updates
                    try {
                        await $`docker pull ${img}`;

                        // Check if image was updated by comparing digests
                        const newDigest = (
                            await $`docker image inspect --format "{{index .RepoDigests 0}}" ${img}`.text()
                        ).trim();

                        if (currentDigest !== newDigest) {
                            if (!quietMode) {
                                log.success(`✓ Updated ${img}`);
                            }
                            stats.updated++;
                        } else {
                            if (!quietMode) {
                                log.success(`✓ ${img} is already up to date`);
                            }
                            stats.alreadyLatest++;
                        }
                    } catch {
                        if (!quietMode) {
                            log.error(`✗ Failed to update ${img}`);
                        }
                        stats.failed++;
                    }
                } catch (error) {
                    if (!quietMode) {
                        log.error(`Error processing ${img}: ${error}`);
                    }
                    stats.failed++;
                }
            }

            // Print summary
            log.info('\nDocker images update summary:');
            log.info(`- Updated:      ${stats.updated}`);
            log.info(`- Up to date:   ${stats.alreadyLatest}`);
            log.info(`- Failed:       ${stats.failed}`);
            log.info(`- Skipped:      ${stats.skipped}`);
            log.info(`- Total images: ${stats.total}`);

            return 0;
        } catch (error) {
            log.error(`Failed to update Docker images: ${error}`);
            return 1;
        }
    },
});
