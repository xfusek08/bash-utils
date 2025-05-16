// File: update-images.ts
import { defineCommand, log } from 'bunner/framework';
import { $ } from 'bun';
import BunnerError from 'bunner/framework/types/BunnerError';
import TextBuilder from 'bunner/framework/text-rendering/TextBuilder';
import Formatter from 'bunner/framework/Formatter/Formatter';

type ImageInfo = {
    name: string;
    currentDigest?: string;
};

type ImageUpdateResult = {
    status: 'updated' | 'current' | 'new' | 'failed';
    name: string;
    error?: string;
    oldDigest?: string;
    newDigest?: string;
};

export default defineCommand({
    command: 'update-images',
    description: 'Update Docker images to their latest versions',
    options: [
        {
            short: 'f',
            long: 'force',
            type: 'boolean',
            description: 'Force update even if image appears current',
            defaultValue: false,
        },
        {
            short: 'q',
            long: 'quiet',
            type: 'boolean',
            description: 'Suppress progress messages',
            defaultValue: false,
        },
    ] as const,
    action: async ({ options }) => {
        try {
            // Get list of images
            const images = await getImageList();

            if (!options.quiet) {
                const tb = new TextBuilder();
                tb.separator('double');
                tb.line(
                    Formatter.withColorHex(
                        ` Docker Images Update - ${images.length} images`,
                        Formatter.SECTION_TITLE_COLOR
                    )
                );
                tb.separator('double');
                tb.line();
                console.log(tb.render());
            }

            // Initialize counters and results
            let updated = 0;
            let upToDate = 0;
            let failed = 0;
            let newImages = 0;
            const results: ImageUpdateResult[] = [];

            for (const img of images) {
                try {
                    const result = await processImage(img, options);
                    results.push(result);

                    switch (result.status) {
                        case 'updated':
                            updated++;
                            break;
                        case 'current':
                            upToDate++;
                            break;
                        case 'new':
                            newImages++;
                            break;
                        case 'failed':
                            failed++;
                            break;
                    }
                } catch (error) {
                    if (!options.quiet) {
                        log.error(`Error processing ${img.name}: ${error}`);
                    }
                    failed++;
                    results.push({
                        status: 'failed',
                        name: img.name,
                        error: String(error),
                    });
                }
            }

            // Print summary
            if (!options.quiet) {
                renderSummaryTable(results, {
                    updated,
                    upToDate,
                    newImages,
                    failed,
                    total: images.length,
                });
            } else {
                console.log(
                    `Updated: ${updated}, Current: ${upToDate}, New: ${newImages}, Failed: ${failed}, Total: ${images.length}`
                );
            }
        } catch (error) {
            throw new BunnerError(`Image update failed: ${error}`, 1);
        }
    },
});

async function getImageList(): Promise<ImageInfo[]> {
    const result =
        await $`docker image ls --format "{{.Repository}}:{{.Tag}}"`.text();
    return result
        .split('\n')
        .filter((line) => line && !line.includes('<none>'))
        .map((name) => ({ name }));
}

async function processImage(
    img: ImageInfo,
    options: { force: boolean; quiet: boolean }
): Promise<ImageUpdateResult> {
    try {
        // Get current digest
        let currentDigest: string | undefined;
        if (!options.force) {
            currentDigest = await getImageDigest(img.name);
        }

        // Pull image
        if (!options.quiet) {
            const statusTb = new TextBuilder();
            statusTb.aligned([
                Formatter.withColorHex('⟳', '#87ceeb'),
                img.name,
                options.force
                    ? Formatter.withColorHex('force-pulling...', '#ffa500')
                    : Formatter.withColorHex('checking...', '#add8e6'),
            ]);
            console.log(statusTb.render());
        }

        await pullImage(img.name, options.quiet);

        // Compare digests
        const newDigest = await getImageDigest(img.name);

        if (!currentDigest) {
            if (!options.quiet) {
                const statusTb = new TextBuilder();
                statusTb.aligned([
                    Formatter.withColorHex('✓', '#00ff00'),
                    img.name,
                    Formatter.withColorHex('newly downloaded', '#00ff00'),
                ]);
                console.log(statusTb.render());
            }
            return { status: 'new', name: img.name, newDigest };
        }

        if (currentDigest !== newDigest) {
            if (!options.quiet) {
                const statusTb = new TextBuilder();
                statusTb.aligned([
                    Formatter.withColorHex('↑', '#00ff00'),
                    img.name,
                    Formatter.withColorHex('updated', '#00ff00'),
                ]);
                console.log(statusTb.render());
            }
            return {
                status: 'updated',
                name: img.name,
                oldDigest: currentDigest,
                newDigest,
            };
        }

        if (!options.quiet) {
            const statusTb = new TextBuilder();
            statusTb.aligned([
                Formatter.withColorHex('=', '#add8e6'),
                img.name,
                Formatter.withColorHex('current', '#add8e6'),
            ]);
            console.log(statusTb.render());
        }
        return {
            status: 'current',
            name: img.name,
            oldDigest: currentDigest,
            newDigest,
        };
    } catch (error) {
        return { status: 'failed', name: img.name, error: String(error) };
    }
}

async function getImageDigest(imageName: string): Promise<string> {
    try {
        const result =
            await $`docker image inspect --format "{{index .RepoDigests 0}}" ${imageName}`.text();
        return result.trim();
    } catch (error) {
        return ''; // Image might have been removed
    }
}

async function pullImage(imageName: string, quiet: boolean): Promise<void> {
    const cmd = quiet
        ? $`docker pull -q ${imageName}`
        : $`docker pull ${imageName}`;

    await cmd.quiet();
}

function renderSummaryTable(
    results: ImageUpdateResult[],
    stats: {
        updated: number;
        upToDate: number;
        newImages: number;
        failed: number;
        total: number;
    }
): void {
    const tb = new TextBuilder({ width: 100 });

    tb.line();
    tb.separator('double');
    tb.line(
        Formatter.withColorHex(
            ' Docker Images Update Summary',
            Formatter.SECTION_TITLE_COLOR
        )
    );
    tb.separator('single');
    tb.line();

    // Status Table
    tb.aligned(['Status', 'Count', 'Percentage']);
    tb.aligned([
        Formatter.withColorHex('Updated', '#00ff00'),
        `${stats.updated}`,
        `${Math.round((stats.updated / stats.total) * 100)}%`,
    ]);
    tb.aligned([
        Formatter.withColorHex('New', '#00ffff'),
        `${stats.newImages}`,
        `${Math.round((stats.newImages / stats.total) * 100)}%`,
    ]);
    tb.aligned([
        Formatter.withColorHex('Current', '#add8e6'),
        `${stats.upToDate}`,
        `${Math.round((stats.upToDate / stats.total) * 100)}%`,
    ]);
    tb.aligned([
        Formatter.withColorHex('Failed', '#ff0000'),
        `${stats.failed}`,
        `${Math.round((stats.failed / stats.total) * 100)}%`,
    ]);
    tb.aligned([
        Formatter.withColorHex('Total', '#ffffff'),
        `${stats.total}`,
        '100%',
    ]);

    tb.line();
    tb.separator('single');

    // Details section if there are updates or failures
    if (stats.updated > 0 || stats.newImages > 0 || stats.failed > 0) {
        tb.line(
            Formatter.withColorHex(
                ' Detailed Results',
                Formatter.SECTION_TITLE_COLOR
            )
        );
        tb.separator('single');

        // Group results by status
        const updatedImages = results.filter((r) => r.status === 'updated');
        const newImages = results.filter((r) => r.status === 'new');
        const failedImages = results.filter((r) => r.status === 'failed');

        // Show updated images
        if (updatedImages.length > 0) {
            tb.line(Formatter.withColorHex('Updated Images:', '#00ff00'));
            tb.indent();
            tb.aligned(['Image', 'Status']);
            for (const img of updatedImages) {
                tb.aligned([
                    img.name,
                    Formatter.withColorHex('↑ updated', '#00ff00'),
                ]);
            }
            tb.unindent();
            tb.line();
        }

        // Show new images
        if (newImages.length > 0) {
            tb.line(Formatter.withColorHex('New Images:', '#00ffff'));
            tb.indent();
            tb.aligned(['Image', 'Status']);
            for (const img of newImages) {
                tb.aligned([
                    img.name,
                    Formatter.withColorHex('✓ downloaded', '#00ffff'),
                ]);
            }
            tb.unindent();
            tb.line();
        }

        // Show failed images
        if (failedImages.length > 0) {
            tb.line(Formatter.withColorHex('Failed Images:', '#ff0000'));
            tb.indent();
            tb.aligned(['Image', 'Error']);
            for (const img of failedImages) {
                tb.aligned([
                    img.name,
                    Formatter.withColorHex(
                        img.error || 'Unknown error',
                        '#ff6347'
                    ),
                ]);
            }
            tb.unindent();
            tb.line();
        }
    }

    tb.separator('double');

    console.log(tb.render());
}
