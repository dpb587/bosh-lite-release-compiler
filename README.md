# bosh-lite-release-compiler

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

A [Concourse](https://concourse.ci/) pipeline task for automatically compiling new releases against new stemcells.

The standalone pipeline example watches S3 for new release/stemcell versions, then starts a new bosh-lite instance (via [aws-bosh-lite-resource](https://github.com/dpb587/aws-bosh-lite-resource)), compiles the release on the stemcell, and then publishes the compiled release to S3.

    # add release settings, s3 credentials, and bosh-lite settings
    $ vim example/pipeline.config.yml
    
    # set the pipeline
    $ fly set-pipeline \
      --pipeline acme:widgetpro-release:ubuntu-compiler \
      --config example/standalone.yml \
      --load-vars-from example/standalone.config.yml


## `compile.yml`

Task which receives the release and stemcell, uploads them, generates a deployment manifest, and exports the release.

Inputs:

 * `release` - with a release tarball
 * `stemcell` - with a stemcell tarball
 * `bosh-lite` - with director-targeting information
 * `bosh-lite-release-compiler` - with `compile.sh` (this repository)

Parameters:

 * `compilation_workers` - number of concurrent compilations to perform (default: `4`)
 * `target_file` - a file with the IP of the BOSH director to use for compilations (default: `bosh-lite/target`)

Outputs:

 * `compiled-release` - with a compiled release tarball named like `release-{release_name}-{release_version}-on-{os_name}-{os_version}-stemcell-{stemcell_version}-compiled-{compilation_version}.tgz`


## License

[MIT License](./LICENSE)
