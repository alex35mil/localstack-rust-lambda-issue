# localstack-rust-lambda-issue

An issue running lambda function written in Rust localy on macOS with LockalStack.

## Prerequisite
1. [rust](https://www.rust-lang.org/tools/install) 
1. [docker](https://docs.docker.com/engine/install/)
1. [localstack](https://docs.localstack.cloud/getting-started/installation/)
1. [cargo-lambda](https://www.cargo-lambda.info/guide/getting-started.html)
1. [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and/or [awslocal](https://github.com/localstack/awscli-local)

Set these vars in your shell:

```
export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=bar
export AWS_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
```

I use Devbox+Nix to setup this environment (see `devbox.json`).

## Run the function with cargo-lambda
1. Run the watcher:

```
cargo lambda watch
```

2. Make request:

```
curl http://localhost:9000
```

You should see the response from the function.

## Reproduce the issue with localstack
1. Create a docker builder:

```
docker buildx create --name lambda-x86-test-builder --platform linux/amd64
```

2. Use the new builder:

```
docker buildx use lambda-x86-test-builder
```

3. Build the docker image:

```
docker buildx build --platform linux/amd64 -t rust-lambda-fn-test-builder . --load
```

4. Build the function binary:

```
docker run --platform linux/amd64 --rm -u $(id -u):$(id -g) -v $PWD:/fn -v $HOME/.cargo/registry:/cargo/registry -v $HOME/.cargo/git:/cargo/git rust-lambda-fn-test-builder localstack-rust-lambda-issue
```

5. Run LockalStack:

```
localstack start
```

6. Deploy the function to LockalStack:

```
cargo lambda deploy --endpoint-url http://localhost:4566 --timeout 900 --binary-path ./build/localstack-rust-lambda-issue -v localstack-rust-lambda-issue
```

7. Invoke the function:

```
aws lambda invoke --function-name localstack-rust-lambda-issue output.txt
```

It results in:

```
2023-12-19T08:18:36.043  INFO --- [   asgi_gw_0] l.u.container_networking   : Determined main container network: bridge
2023-12-19T08:18:36.048  INFO --- [   asgi_gw_0] l.u.container_networking   : Determined main container target IP: 172.17.0.4
2023-12-19T08:18:46.028  WARN --- [   Thread-26] l.s.l.i.execution_environm : Execution environment e6e9f4f31ccbb5c92b2143ed49995d4c for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST timed out during startup. Check for errors during the startup of your Lambda function and consider increasing the startup timeout via LAMBDA_RUNTIME_ENVIRONMENT_TIMEOUT.
```

<details>
<summary>
    Detailed log: <code>LAMBDA_RUNTIME_ENVIRONMENT_TIMEOUT=30 DEBUG=1 localstack start</code>
</summary>

```
     __                     _______ __             __
    / /   ____  _________ _/ / ___// /_____ ______/ /__
   / /   / __ \/ ___/ __ `/ /\__ \/ __/ __ `/ ___/ //_/
  / /___/ /_/ / /__/ /_/ / /___/ / /_/ /_/ / /__/ ,<
 /_____/\____/\___/\__,_/_//____/\__/\__,_/\___/_/|_|

 💻 LocalStack CLI 3.0.0

[12:30:59] starting LocalStack in Docker mode 🐳                                                                                                                                                                                                                       localstack.py:495
2023-12-19T12:30:59.842 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='activate_pro_key_on_host', value='localstack_ext.plugins:activate_pro_key_on_host', group='localstack.hooks.prepare_host')
2023-12-19T12:30:59.845 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='configure_extensions_dev_host', value='localstack_ext.extensions.plugins:configure_extensions_dev_host', group='localstack.hooks.prepare_host')
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='patch_community_pro_detection', value='localstack_ext.plugins:patch_community_pro_detection', group='localstack.hooks.prepare_host')
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='start_ec2_daemon', value='localstack_ext.plugins:start_ec2_daemon', group='localstack.hooks.prepare_host')
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.prepare_host.activate_pro_key_on_host = <function activate_pro_key_on_host at 0x1073e5d00>)
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.prepare_host:activate_pro_key_on_host is disabled
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.prepare_host.configure_extensions_dev_host = <function configure_extensions_dev_host at 0x1073e6fc0>)
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.prepare_host:configure_extensions_dev_host is disabled
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.prepare_host.patch_community_pro_detection = <function patch_community_pro_detection at 0x1073e5bc0>)
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.prepare_host:patch_community_pro_detection
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.prepare_host.start_ec2_daemon = <function start_ec2_daemon at 0x1073e5e40>)
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.prepare_host:start_ec2_daemon is disabled
2023-12-19T12:30:59.846 DEBUG --- [  MainThread] localstack.utils.run       : Executing command: ['docker', 'ps']
2023-12-19T12:30:59.921 DEBUG --- [  MainThread] localstack.utils.run       : Executing command: ['docker', 'ps', '--format', '{{json . }}']
2023-12-19T12:30:59.978 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='configure_extensions_dev_container', value='localstack_ext.extensions.plugins:configure_extensions_dev_container', group='localstack.hooks.configure_localstack_container
')
2023-12-19T12:30:59.978 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='configure_pro_container', value='localstack_ext.plugins:configure_pro_container', group='localstack.hooks.configure_localstack_container')
2023-12-19T12:30:59.978 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.configure_localstack_container.configure_extensions_dev_container = <function configure_extensions_dev_container at 0x1073e6e80>)
2023-12-19T12:30:59.979 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.configure_localstack_container:configure_extensions_dev_container is disabled
2023-12-19T12:30:59.979 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.configure_localstack_container.configure_pro_container = <function configure_pro_container at 0x1073e5f80>)
2023-12-19T12:30:59.979 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.configure_localstack_container:configure_pro_container is disabled
2023-12-19T12:30:59.979 DEBUG --- [  MainThread] l.u.c.docker_cmd_client    : Run container with cmd: ['docker', 'run', '--rm', '--entrypoint', 'sh', '-p', '0.0.0.0:53:53/udp', '-p', '0.0.0.0:53:53', 'localstack/localstack', '-c', 'echo test123']
2023-12-19T12:30:59.979 DEBUG --- [  MainThread] localstack.utils.run       : Executing command: ['docker', 'run', '--rm', '--entrypoint', 'sh', '-p', '0.0.0.0:53:53/udp', '-p', '0.0.0.0:53:53', 'localstack/localstack', '-c', 'echo test123']
2023-12-19T12:31:00.065 DEBUG --- [  MainThread] localstack.utils.run       : Executing command: ['docker', 'inspect', '--format', '{{json .}}', 'localstack/localstack']
2023-12-19T12:31:00.122 DEBUG --- [-functhread1] localstack.utils.bootstrap : starting LocalStack container
2023-12-19T12:31:00.123 DEBUG --- [-functhread1] l.u.c.docker_cmd_client    : Create container with cmd: ['docker', 'create', '--rm', '--name', 'localstack-main', '-v', '/Users/Alex/Library/Caches/localstack/volume:/var/lib/localstack', '-v', '/var/run/docker.sock:/var/run/docker
.sock', '-p', '127.0.0.1:4510-4560:4510-4560', '-p', '127.0.0.1:4566:4566', '-e', 'EXTERNAL_SERVICE_PORTS_START=4510', '-e', 'EXTERNAL_SERVICE_PORTS_END=4560', '-e', 'DOCKER_HOST=unix:///var/run/docker.sock', '-e', 'ACTIVATE_PRO=0', '-e', 'DEBUG=1', '-e', 'LAMBDA_RUNTIME_ENVIRONM
ENT_TIMEOUT=30', '-e', 'GATEWAY_LISTEN=:4566', 'localstack/localstack']
2023-12-19T12:31:00.123 DEBUG --- [-functhread1] localstack.utils.run       : Executing command: ['docker', 'create', '--rm', '--name', 'localstack-main', '-v', '/Users/Alex/Library/Caches/localstack/volume:/var/lib/localstack', '-v', '/var/run/docker.sock:/var/run/docker.sock',
'-p', '127.0.0.1:4510-4560:4510-4560', '-p', '127.0.0.1:4566:4566', '-e', 'EXTERNAL_SERVICE_PORTS_START=4510', '-e', 'EXTERNAL_SERVICE_PORTS_END=4560', '-e', 'DOCKER_HOST=unix:///var/run/docker.sock', '-e', 'ACTIVATE_PRO=0', '-e', 'DEBUG=1', '-e', 'LAMBDA_RUNTIME_ENVIRONMENT_TIME
OUT=30', '-e', 'GATEWAY_LISTEN=:4566', 'localstack/localstack']
⠋ Starting LocalStack container2023-12-19T12:31:00.205 DEBUG --- [-functhread1] l.u.c.docker_cmd_client    : Start container with cmd: ['docker', 'start', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
2023-12-19T12:31:00.205 DEBUG --- [-functhread1] localstack.utils.run       : Executing command: ['docker', 'start', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
⠼ Starting LocalStack container2023-12-19T12:31:00.541 DEBUG --- [-functhread1] localstack.utils.run       : Executing command: ['docker', 'inspect', '--format', '{{json .}}', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
2023-12-19T12:31:00.585 DEBUG --- [-functhread1] l.u.c.docker_cmd_client    : Attaching to container 3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3
2023-12-19T12:31:00.585 DEBUG --- [-functhread1] localstack.utils.run       : Executing command: ['docker', 'attach', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
⠴ Starting LocalStack container2023-12-19T12:31:00.625 DEBUG --- [-log-printer] localstack.utils.run       : Executing command: ['docker', 'inspect', '--format', '{{json .}}', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
2023-12-19T12:31:00.671 DEBUG --- [-log-printer] localstack.utils.run       : Executing command: ['docker', 'inspect', '--format', '{{json .}}', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3']
⠦ Starting LocalStack container2023-12-19T12:31:00.717 DEBUG --- [-log-printer] localstack.utils.run       : Executing command: ['docker', 'logs', '3d34477653bf7cc729f328ff0c6826651f56920b64975ee2e5f163ef3ab6a1a3', '--follow']
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────── LocalStack Runtime Log (press CTRL-C to quit) ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
LocalStack supervisor: starting
LocalStack supervisor: localstack process (PID 15) starting
Profile 'default' specified, but file /root/.localstack/default.env not found.

LocalStack version: 3.0.3.dev
LocalStack Docker container id: 3d34477653bf
LocalStack build date: 2023-12-18
LocalStack build git hash: fb182b7a

2023-12-19T08:31:00.836 DEBUG --- [  MainThread] stevedore._cache           : reading /root/.cache/python-entrypoints/4b23ebd1a12bd8ef66e85bea90f811995637a60e9f59f022617800a1800c194d
2023-12-19T08:31:00.838 DEBUG --- [  MainThread] stevedore._cache           : writing to /root/.cache/python-entrypoints/4b23ebd1a12bd8ef66e85bea90f811995637a60e9f59f022617800a1800c194d
2023-12-19T08:31:00.839 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='_patch_botocore_json_parser', value='localstack.aws.client:_patch_botocore_json_parser', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.840 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='_publish_config_as_analytics_event', value='localstack.runtime.analytics:_publish_config_as_analytics_event', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.840 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='_publish_container_info', value='localstack.runtime.analytics:_publish_container_info', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.840 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='_run_init_scripts_on_start', value='localstack.runtime.init:_run_init_scripts_on_start', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.841 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='deprecation_warnings', value='localstack.plugins:deprecation_warnings', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.841 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='register_partition_adjusting_proxy_listener', value='localstack.plugins:register_partition_adjusting_proxy_listener', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.841 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='setup_dns_configuration_on_host', value='localstack.dns.plugins:setup_dns_configuration_on_host', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.842 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='start_dns_server', value='localstack.dns.plugins:start_dns_server', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.842 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='validate_configuration', value='localstack.services.lambda_.plugins:validate_configuration', group='localstack.hooks.on_infra_start')
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start._patch_botocore_json_parser = <function _patch_botocore_json_parser at 0xffff9c3618a0>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:_patch_botocore_json_parser
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start._publish_config_as_analytics_event = <function _publish_config_as_analytics_event at 0xffff9c361b20>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:_publish_config_as_analytics_event
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start._publish_container_info = <function _publish_container_info at 0xffff9c361ee0>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:_publish_container_info
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start._run_init_scripts_on_start = <function _run_init_scripts_on_start at 0xffff9c362e80>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:_run_init_scripts_on_start
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start.deprecation_warnings = <function deprecation_warnings at 0xffff9c363600>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:deprecation_warnings
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start.register_partition_adjusting_proxy_listener = <function register_partition_adjusting_proxy_listener at 0xffff9c3634c0>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.on_infra_start:register_partition_adjusting_proxy_listener is disabled
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start.setup_dns_configuration_on_host = <function setup_dns_configuration_on_host at 0xffff9c363920>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:setup_dns_configuration_on_host
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start.start_dns_server = <function start_dns_server at 0xffff9c3637e0>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:start_dns_server
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_start.validate_configuration = <function validate_configuration at 0xffff9c3ab1a0>)
2023-12-19T08:31:00.843 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_start:validate_configuration
2023-12-19T08:31:00.855 DEBUG --- [  MainThread] localstack.dns.server      : Determined fallback dns: 192.168.65.7
2023-12-19T08:31:00.856 DEBUG --- [  MainThread] localstack.dns.server      : Starting DNS servers (tcp/udp port 53 on 0.0.0.0)...
2023-12-19T08:31:00.856 DEBUG --- [  MainThread] localstack.dns.server      : Adding host .*localhost.localstack.cloud pointing to LocalStack
2023-12-19T08:31:00.856 DEBUG --- [  MainThread] localstack.dns.server      : Adding host .*localhost.localstack.cloud with record DynamicRecord(record_type=<RecordType.A: 1>, record_id=None)
2023-12-19T08:31:00.856 DEBUG --- [  MainThread] localstack.dns.server      : Adding host .*localhost.localstack.cloud with record DynamicRecord(record_type=<RecordType.AAAA: 2>, record_id=None)
2023-12-19T08:31:00.857 DEBUG --- [-functhread1] localstack.dns.server      : DNS Server started
2023-12-19T08:31:01.883 DEBUG --- [  MainThread] localstack.dns.server      : DNS server startup finished.
2023-12-19T08:31:01.884 DEBUG --- [  MainThread] localstack.runtime.init    : Init scripts discovered: {BOOT: [], START: [], READY: [], SHUTDOWN: []}
2023-12-19T08:31:01.884 DEBUG --- [  MainThread] localstack.plugins         : Checking for the usage of deprecated community features and configs...
2023-12-19T08:31:01.885 DEBUG --- [  MainThread] localstack.dns.server      : Overwriting container DNS server to point to localhost
2023-12-19T08:31:01.894 DEBUG --- [  MainThread] localstack.utils.threads   : start_thread called without providing a custom name
2023-12-19T08:31:01.894 DEBUG --- [-functhread3] localstack.utils.run       : Executing command: whoami
2023-12-19T08:31:01.977  WARN --- [-functhread3] l.services.internal        : Enabling diagnose endpoint, please be aware that this can expose sensitive information via your network.
2023-12-19T08:31:01.979 DEBUG --- [-functhread3] localstack.utils.ssl       : Using cached SSL certificate (less than 6hrs since last update).
2023-12-19T08:31:01.984  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
2023-12-19T08:31:01.984  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
2023-12-19T08:31:02.200 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='acm:default', value='localstack.services.providers:acm', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='apigateway:default', value='localstack.services.providers:apigateway', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='cloudformation:default', value='localstack.services.providers:cloudformation', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='cloudwatch:default', value='localstack.services.providers:cloudwatch', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='config:default', value='localstack.services.providers:awsconfig', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='dynamodb:default', value='localstack.services.providers:dynamodb', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='dynamodbstreams:default', value='localstack.services.providers:dynamodbstreams', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='ec2:default', value='localstack.services.providers:ec2', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='es:default', value='localstack.services.providers:es', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='events:default', value='localstack.services.providers:events', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='firehose:default', value='localstack.services.providers:firehose', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='iam:default', value='localstack.services.providers:iam', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='kinesis:default', value='localstack.services.providers:kinesis', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='kms:default', value='localstack.services.providers:kms', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='lambda:asf', value='localstack.services.providers:lambda_asf', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='lambda:default', value='localstack.services.providers:lambda_', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='lambda:v2', value='localstack.services.providers:lambda_v2', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='logs:default', value='localstack.services.providers:logs', group='localstack.aws.provider')
2023-12-19T08:31:02.202 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='opensearch:default', value='localstack.services.providers:opensearch', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='redshift:default', value='localstack.services.providers:redshift', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='resource-groups:default', value='localstack.services.providers:resource_groups', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='resourcegroupstaggingapi:default', value='localstack.services.providers:resourcegroupstaggingapi', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='route53:default', value='localstack.services.providers:route53', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='route53resolver:default', value='localstack.services.providers:route53resolver', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:asf', value='localstack.services.providers:s3_asf', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:default', value='localstack.services.providers:s3', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:legacy_v2', value='localstack.services.providers:s3_legacy_v2', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:stream', value='localstack.services.providers:s3_stream', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:v2', value='localstack.services.providers:s3_v2', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3:v3', value='localstack.services.providers:s3_v3', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='s3control:default', value='localstack.services.providers:s3control', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='scheduler:default', value='localstack.services.providers:scheduler', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='secretsmanager:default', value='localstack.services.providers:secretsmanager', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='ses:default', value='localstack.services.providers:ses', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='sns:default', value='localstack.services.providers:sns', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='sqs-query:default', value='localstack.services.providers:sqs_query', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='sqs:default', value='localstack.services.providers:sqs', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='ssm:default', value='localstack.services.providers:ssm', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='stepfunctions:default', value='localstack.services.providers:stepfunctions', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='stepfunctions:legacy', value='localstack.services.providers:stepfunctions_v1', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='stepfunctions:v1', value='localstack.services.providers:stepfunctions_legacy', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='stepfunctions:v2', value='localstack.services.providers:stepfunctions_v2', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='sts:default', value='localstack.services.providers:sts', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='support:default', value='localstack.services.providers:support', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='swf:default', value='localstack.services.providers:swf', group='localstack.aws.provider')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='transcribe:default', value='localstack.services.providers:transcribe', group='localstack.aws.provider')
Ready.
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='_run_init_scripts_on_ready', value='localstack.runtime.init:_run_init_scripts_on_ready', group='localstack.hooks.on_infra_ready')
2023-12-19T08:31:02.203 DEBUG --- [  MainThread] stevedore.extension        : found extension EntryPoint(name='register_virtual_host_routes', value='localstack.services.s3.virtual_host:register_virtual_host_routes', group='localstack.hooks.on_infra_ready')
2023-12-19T08:31:02.204 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_ready._run_init_scripts_on_ready = <function _run_init_scripts_on_ready at 0xffff9c362fc0>)
2023-12-19T08:31:02.204 DEBUG --- [  MainThread] plugin.manager             : loading plugin localstack.hooks.on_infra_ready:_run_init_scripts_on_ready
2023-12-19T08:31:02.204 DEBUG --- [  MainThread] plugin.manager             : instantiating plugin PluginSpec(localstack.hooks.on_infra_ready.register_virtual_host_routes = <function register_virtual_host_routes at 0xffff980b0ea0>)
2023-12-19T08:31:02.204 DEBUG --- [  MainThread] plugin.manager             : plugin localstack.hooks.on_infra_ready:register_virtual_host_routes is disabled
2023-12-19T08:31:10.753 DEBUG --- [   asgi_gw_0] l.a.p.service_router       : loading service catalog index cache file /var/lib/localstack/cache/service-catalog-3_0_3_dev-1_32_5.pickle

2023-12-19T08:41:24.756 DEBUG --- [   asgi_gw_0] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.lambda:default = <function lambda_ at 0xffff98ca62a0>)
2023-12-19T08:41:24.756 DEBUG --- [   asgi_gw_0] plugin.manager             : loading plugin localstack.aws.provider:lambda:default
2023-12-19T08:41:24.875 DEBUG --- [   asgi_gw_0] plugin.manager             : no extensions found in namespace localstack.hooks.lambda_inject_layer_fetcher
2023-12-19T08:41:24.888 DEBUG --- [   asgi_gw_0] l.s.lambda_.urlrouter      : Registering parameterized Lambda routes.
2023-12-19T08:41:24.889 DEBUG --- [   asgi_gw_0] stevedore.extension        : found extension EntryPoint(name='docker', value='localstack.services.lambda_.invocation.plugins:DockerRuntimeExecutorPlugin', group='localstack.lambda.runtime_executor')
2023-12-19T08:41:24.889 DEBUG --- [   asgi_gw_0] plugin.manager             : instantiating plugin PluginSpec(localstack.lambda.runtime_executor.docker = <class 'localstack.services.lambda_.invocation.plugins.DockerRuntimeExecutorPlugin'>)
2023-12-19T08:41:24.889 DEBUG --- [   asgi_gw_0] plugin.manager             : loading plugin localstack.lambda.runtime_executor:docker
2023-12-19T08:41:24.991  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS lambda.GetFunction => 404 (ResourceNotFoundException)
2023-12-19T08:41:25.022 DEBUG --- [   asgi_gw_0] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.sts:default = <function sts at 0xffff98ca5ee0>)
2023-12-19T08:41:25.022 DEBUG --- [   asgi_gw_0] plugin.manager             : loading plugin localstack.aws.provider:sts:default
2023-12-19T08:41:25.083  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS sts.GetCallerIdentity => 200
2023-12-19T08:41:25.094 DEBUG --- [   asgi_gw_0] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.iam:default = <function iam at 0xffff98ca5da0>)
2023-12-19T08:41:25.094 DEBUG --- [   asgi_gw_0] plugin.manager             : loading plugin localstack.aws.provider:iam:default
2023-12-19T08:41:25.108  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS iam.CreateRole => 200
2023-12-19T08:41:25.113  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS iam.AttachRolePolicy => 200
2023-12-19T08:41:30.142  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS sts.AssumeRole => 200
2023-12-19T08:41:30.160  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS iam.UpdateAssumeRolePolicy => 200
2023-12-19T08:41:30.385 DEBUG --- [   asgi_gw_1] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.s3:default = <function s3 at 0xffff98ca6fc0>)
2023-12-19T08:41:30.385 DEBUG --- [   asgi_gw_1] plugin.manager             : loading plugin localstack.aws.provider:s3:default
2023-12-19T08:41:30.546 DEBUG --- [rvice-task_1] plugin.manager             : no extensions found in namespace localstack.hooks.lambda_prepare_docker_executors
2023-12-19T08:41:30.547  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS lambda.CreateFunction => 201
2023-12-19T08:41:30.547 DEBUG --- [rvice-task_1] l.s.l.i.lambda_models      : Saving code localstack-rust-lambda-issue-4e891f84-c749-429a-8e7d-ebe9c62eea69 to disk
2023-12-19T08:41:30.581 DEBUG --- [rvice-task_1] localstack.utils.run       : Executing command: ['unzip', '-o', '-q', '/tmp/tmp4t0ddmsh']
2023-12-19T08:41:30.646 DEBUG --- [rvice-task_1] l.u.c.docker_sdk_client    : Pulling Docker image: public.ecr.aws/lambda/provided:al2
2023-12-19T08:41:30.647 DEBUG --- [rvice-task_0] l.u.c.docker_sdk_client    : Pulling Docker image: public.ecr.aws/lambda/provided:al2
2023-12-19T08:41:33.324 DEBUG --- [rvice-task_0] l.s.l.i.version_manager    : Version preparation of function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST took 2776.03ms
2023-12-19T08:41:33.324 DEBUG --- [rvice-task_0] l.s.l.i.version_manager    : Changing Lambda arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST (id e8335460) to active
2023-12-19T08:41:33.324 DEBUG --- [rvice-task_0] l.s.l.i.event_manager      : Starting event manager arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST id 281472724813840
2023-12-19T08:41:33.328 DEBUG --- [rvice-task_1] l.s.l.i.version_manager    : Version preparation of function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:1 took 2781.98ms
2023-12-19T08:41:33.328 DEBUG --- [rvice-task_1] l.s.l.i.version_manager    : Changing Lambda arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:1 (id e8335460) to active
2023-12-19T08:41:33.340 DEBUG --- [   asgi_gw_1] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.sqs:default = <function sqs at 0xffff98ca7a60>)
2023-12-19T08:41:33.340 DEBUG --- [   asgi_gw_1] plugin.manager             : loading plugin localstack.aws.provider:sqs:default
2023-12-19T08:41:33.419 DEBUG --- [   asgi_gw_1] l.services.sqs.provider    : creating queue key=localstack-rust-lambda-issue-c644e010cfa48883bfe2b77ea72603bb attributes=None tags=None
2023-12-19T08:41:33.426 DEBUG --- [rvice-task_1] l.s.l.i.event_manager      : Starting event manager arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:1 id 281471990980752
2023-12-19T08:41:33.432 DEBUG --- [   asgi_gw_1] l.services.sqs.provider    : creating queue key=localstack-rust-lambda-issue-1bb8ee6673668622a56d1b252212b94d attributes=None tags=None
2023-12-19T08:41:35.472 DEBUG --- [   asgi_gw_0] plugin.manager             : instantiating plugin PluginSpec(localstack.aws.provider.cloudwatch:default = <function cloudwatch at 0xffff98ca5620>)
2023-12-19T08:41:35.472 DEBUG --- [   asgi_gw_0] plugin.manager             : loading plugin localstack.aws.provider:cloudwatch:default
2023-12-19T08:41:35.477 DEBUG --- [   asgi_gw_0] l.s.cloudwatch.provider    : starting cloudwatch scheduler

2023-12-19T08:41:56.354 DEBUG --- [   asgi_gw_2] l.s.l.i.assignment         : Starting new environment
2023-12-19T08:41:56.355 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor a418b129cf833005cc3b33773d283aa7
2023-12-19T08:41:56.355 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Finished creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor a418b129cf833005cc3b33773d283aa7
2023-12-19T08:41:56.355 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Assigning container name of localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7 to executor a418b129cf833005cc3b33773d283aa7
2023-12-19T08:41:56.370 DEBUG --- [   asgi_gw_2] l.u.c.container_client     : Getting networks for container: localstack-main
2023-12-19T08:41:56.374  INFO --- [   asgi_gw_2] l.u.container_networking   : Determined main container network: bridge
2023-12-19T08:41:56.374 DEBUG --- [   asgi_gw_2] l.u.c.container_client     : Getting ipv4 address for container localstack-main in network bridge.
2023-12-19T08:41:56.379  INFO --- [   asgi_gw_2] l.u.container_networking   : Determined main container target IP: 172.17.0.4
2023-12-19T08:41:56.380 DEBUG --- [   asgi_gw_2] plugin.manager             : no extensions found in namespace localstack.hooks.lambda_start_docker_executor
2023-12-19T08:41:56.381 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Creating container with attributes: {'self': <localstack.utils.container_utils.docker_sdk_client.SdkDockerClient object at 0xffff9cb9b690>, 'image_name': 'public.ecr.aws/lambda/provided:al2', 'name': 'l
ocalstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7', 'entrypoint': '/var/rapid/init', 'remove': False, 'interactive': False, 'tty': False, 'detach': False, 'command': None, 'mount_volumes': [], 'ports': <PortMappings: {}>, 'exposed_ports': [], 'en
v_vars': {'AWS_DEFAULT_REGION': 'us-east-1', 'AWS_REGION': 'us-east-1', 'AWS_LAMBDA_FUNCTION_NAME': 'localstack-rust-lambda-issue', 'AWS_LAMBDA_FUNCTION_MEMORY_SIZE': 128, 'AWS_LAMBDA_FUNCTION_VERSION': '$LATEST', 'AWS_LAMBDA_INITIALIZATION_TYPE': 'on-demand', 'AWS_LAMBDA_LOG_GRO
UP_NAME': '/aws/lambda/localstack-rust-lambda-issue', 'AWS_LAMBDA_LOG_STREAM_NAME': '2023/12/19/[$LATEST]a418b129cf833005cc3b33773d283aa7', 'AWS_ACCESS_KEY_ID': 'LSIAQAAAAAAAGMHHFGKK', 'AWS_SECRET_ACCESS_KEY': 'CYbKeCX0S5a7nWkijRZyJBTrzGZ9ZcfAtIOhIksu', 'AWS_SESSION_TOKEN': 'FQoG
ZXIvYXdzEBYaDEcPQWircYa03RY+c+591gzY4Lpm5Rf1cwa9MAsQvP32S87QI3C8SLn6sSdujOBaZ/5DuuzJHMH27b8uU+qOxRfbCBvyZRUQ7hhtHjzmQIbCra1Ug0w6Gw2m5nhDozWmGBk+x7ecHl0N4ZuSjrUce+fxWOmtURdZWjmkjIBUSPX2J4i38PXcN9EAns7TJt3vnf9FP7Ef6JegifKANRCpFY/LWb/Je/CQZFvOh47ERzi41dHOPwX9hgc72Mnn//ban7ZNLytz9OK1
9fhGJhEjHRpyfkKYvpBT1432CTlCqgKruTJbCNujVvf28JXX4gHZRVYUkTRGFuYjG6+kE8s=', 'LAMBDA_TASK_ROOT': '/var/task', 'LAMBDA_RUNTIME_DIR': '/var/runtime', 'AWS_XRAY_CONTEXT_MISSING': 'LOG_ERROR', 'AWS_XRAY_DAEMON_ADDRESS': '127.0.0.1:2000', '_AWS_XRAY_DAEMON_PORT': '2000', '_AWS_XRAY_DAEM
ON_ADDRESS': '127.0.0.1', 'TZ': ':UTC', 'AWS_LAMBDA_FUNCTION_TIMEOUT': 900, 'LOCALSTACK_HOSTNAME': '172.17.0.4', 'EDGE_PORT': '4566', 'LOCALSTACK_RUNTIME_ID': 'a418b129cf833005cc3b33773d283aa7', 'LOCALSTACK_RUNTIME_ENDPOINT': 'http://172.17.0.4:4566/_localstack_lambda/a418b129cf8
33005cc3b33773d283aa7', 'AWS_ENDPOINT_URL': 'http://172.17.0.4:4566', '_HANDLER': 'bootstrap', 'AWS_EXECUTION_ENV': 'Aws_Lambda_provided.al2', 'LOCALSTACK_INIT_LOG_LEVEL': 'debug'}, 'user': None, 'cap_add': None, 'cap_drop': None, 'security_opt': None, 'network': 'bridge', 'dns':
 '172.17.0.4', 'additional_flags': '', 'workdir': None, 'privileged': False, 'labels': None, 'platform': 'linux/amd64', 'ulimits': None}
2023-12-19T08:41:56.412 DEBUG --- [   asgi_gw_2] localstack.packages.api    : Installation of lambda-runtime skipped (already installed).
2023-12-19T08:41:56.412 DEBUG --- [   asgi_gw_2] localstack.packages.api    : Performing runtime setup for already installed package.
2023-12-19T08:41:56.412 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Copying file /usr/lib/localstack/lambda-runtime/v0.1.24-pre/arm64/. into localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7:/
2023-12-19T08:41:56.516 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Copying file /tmp/lambda/awslambda-us-east-1-tasks/localstack-rust-lambda-issue-4e891f84-c749-429a-8e7d-ebe9c62eea69/code/. into localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b3
3773d283aa7:/var/task
2023-12-19T08:41:56.598 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Starting container localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7
2023-12-19T08:41:56.701 DEBUG --- [   asgi_gw_2] l.u.c.container_client     : Getting ipv4 address for container localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7 in network bridge.
2023-12-19T08:42:26.361  WARN --- [   Thread-76] l.s.l.i.execution_environm : Execution environment a418b129cf833005cc3b33773d283aa7 for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST timed out during startup. Check for errors during
the startup of your Lambda function and consider increasing the startup timeout via LAMBDA_RUNTIME_ENVIRONMENT_TIMEOUT.
2023-12-19T08:42:26.403 DEBUG --- [   Thread-76] l.s.l.i.execution_environm : Logs from the execution environment a418b129cf833005cc3b33773d283aa7 after startup timeout:
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="No code archives set. Skipping download." func=main.DownloadCodeArchives file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/codearchive.go:21"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="DNS server disabled." func=main.RunDNSRewriter file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:145"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Bootstrap not executable, setting permissions to 0755.../var/task/bootstrap" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:85"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=warning msg="Error setting bootstrap to 0755 permissions: /var/task/bootstrapchmod /var/task/bootstrap: no such file or directory" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda
-runtime-init/cmd/localstack/awsutil.go:88"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Process running as root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:164" euid=0 gid=0 uid=0 username=root
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] Initializing AWS X-Ray daemon unknown
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Listening on UDP 127.0.0.1:2000
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Process running as non-root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:169" euid=993 gid=990 uid=993 username=sbx_user1051
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] Using buffer memory limit of 99 MB
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] 1584 segment buffers allocated
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Using Endpoint read from Config file: http://172.17.0.4:4566
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Using proxy address:
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Fetch region us-east-1 from commandline/config file
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] Using region: us-east-1
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] HTTP Proxy server using X-Ray Endpoint : http://172.17.0.4:4566
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Using Endpoint: http://172.17.0.4:4566
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Debug] Batch size: 10
[lambda a418b129cf833005cc3b33773d283aa7] 2023-12-19T08:41:56Z [Info] Starting proxy http server on 127.0.0.1:2000
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Starting runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:232"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=info msg="Configure environment for Init Caching." func="go.amzn.com/lambda/rapid.(*rapidContext).acceptInitRequestForInitCaching" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/ra
pid/start.go:552"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=info msg="extensionsDisabledByLayer(/opt/disable-extensions-jwigqn8j) -> stat /opt/disable-extensions-jwigqn8j: no such file or directory" func=go.amzn.com/lambda/rapid.extensionsDisabledByLayer file="/ho
me/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:522"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Received RUNNING: {43574809636471 43574809902262 0 43574809636471 true 0x40000f8a20}" func="go.amzn.com/lambda/rapidcore.(*Server).Init" file="/home/runner/work/lambda-runtime-init/lambda-runti
me-init/lambda/rapidcore/server.go:510"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Awaiting initialization of runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:235"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=info msg="Configuring and starting Operator Domain" func=go.amzn.com/lambda/rapid.doOperatorDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:255"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=info msg="Starting runtime domain" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:302"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=warning msg="Cannot list external agents" func=go.amzn.com/lambda/agents.ListExternalAgentPaths file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/agents/agent.go:24" error="open /opt/
extensions: no such file or directory"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Preregister runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:329"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Start runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:349"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Hot reloading disabled." func=main.RunHotReloadingListener file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:162"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=debug msg="Runtime API Server listening on 127.0.0.1:9001" func="go.amzn.com/lambda/rapi.(*Server).Listen" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapi/server.go:102"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=warning msg="First fatal error stored in appctx: Runtime.InvalidEntrypoint" func=go.amzn.com/lambda/appctx.StoreFirstFatalError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/appct
x/appctxutil.go:157"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=error msg="Init failed" func=go.amzn.com/lambda/rapid.handleInitError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/exit.go:109" InvokeID= error="fork/exec /var/task/bootstr
ap: no such file or directory"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=info msg="Error releasing after init failure InitDoneFailed: NotReserved" func="go.amzn.com/lambda/rapidcore.(*Server).AwaitInitialized" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lam
bda/rapidcore/server.go:754"
[lambda a418b129cf833005cc3b33773d283aa7] time="2023-12-19T08:41:56Z" level=error msg="Runtime init failed to initialize: InitDoneFailed. Exiting." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:238"
[lambda a418b129cf833005cc3b33773d283aa7]
2023-12-19T08:42:26.403 DEBUG --- [   Thread-76] l.u.c.docker_sdk_client    : Stopping container: localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7
2023-12-19T08:42:26.409 DEBUG --- [   Thread-76] l.u.c.docker_sdk_client    : Removing container: localstack-main-lambda-localstack-rust-lambda-issue-a418b129cf833005cc3b33773d283aa7
2023-12-19T08:42:26.446  INFO --- [   asgi_gw_2] localstack.request.aws     : AWS lambda.Invoke => 500 (ServiceException)
2023-12-19T08:42:27.074 DEBUG --- [   asgi_gw_4] l.s.l.i.assignment         : Starting new environment
2023-12-19T08:42:27.074 DEBUG --- [   asgi_gw_4] l.s.l.i.docker_runtime_exe : Creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor 826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:27.074 DEBUG --- [   asgi_gw_4] l.s.l.i.docker_runtime_exe : Finished creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor 826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:27.075 DEBUG --- [   asgi_gw_4] l.s.l.i.docker_runtime_exe : Assigning container name of localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a to executor 826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:27.094 DEBUG --- [   asgi_gw_4] l.u.c.docker_sdk_client    : Creating container with attributes: {'self': <localstack.utils.container_utils.docker_sdk_client.SdkDockerClient object at 0xffff9cb9b690>, 'image_name': 'public.ecr.aws/lambda/provided:al2', 'name': 'l
ocalstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a', 'entrypoint': '/var/rapid/init', 'remove': False, 'interactive': False, 'tty': False, 'detach': False, 'command': None, 'mount_volumes': [], 'ports': <PortMappings: {}>, 'exposed_ports': [], 'en
v_vars': {'AWS_DEFAULT_REGION': 'us-east-1', 'AWS_REGION': 'us-east-1', 'AWS_LAMBDA_FUNCTION_NAME': 'localstack-rust-lambda-issue', 'AWS_LAMBDA_FUNCTION_MEMORY_SIZE': 128, 'AWS_LAMBDA_FUNCTION_VERSION': '$LATEST', 'AWS_LAMBDA_INITIALIZATION_TYPE': 'on-demand', 'AWS_LAMBDA_LOG_GRO
UP_NAME': '/aws/lambda/localstack-rust-lambda-issue', 'AWS_LAMBDA_LOG_STREAM_NAME': '2023/12/19/[$LATEST]826adaab2cb8475c7c36d201edf5fe9a', 'AWS_ACCESS_KEY_ID': 'LSIAQAAAAAAAGWIZGMEF', 'AWS_SECRET_ACCESS_KEY': 'rZiQ/XuXBBbe6eTY4aX/hUYCOViNdabOTu8ZeA+7', 'AWS_SESSION_TOKEN': 'FQoG
ZXIvYXdzEBYaDj9YCGVKm0mHsByVBB9kXiH/mk9jPHvgNWQCaxy8OTIT63CuEpAbTfkThlbU0CLx/DKOZudd8oghsRaM0Y/Cl9Dm1HVmGIyV4fRNFYKdgFgdrqEJJeteARDEcR9ctmsizEkPxsJfKT/9FU86ZqkIeIsN24LAs+dpCebcwSI3TbnLGGVJWQJNQGItxKCXvfvBWb6UJMODxRSpoMVnDqKKuDT6yftyLeCGAIgfg1vusnnGWHnHYzv3nOvm52dIKFdSqpd607DB9W1i
RfwpMDPRG0Fji2d4P78dOjgV7OysDNJe0EKmhK8+JwqLOMwaShMwhn6wbFIldIj8nyyg3aI=', 'LAMBDA_TASK_ROOT': '/var/task', 'LAMBDA_RUNTIME_DIR': '/var/runtime', 'AWS_XRAY_CONTEXT_MISSING': 'LOG_ERROR', 'AWS_XRAY_DAEMON_ADDRESS': '127.0.0.1:2000', '_AWS_XRAY_DAEMON_PORT': '2000', '_AWS_XRAY_DAEM
ON_ADDRESS': '127.0.0.1', 'TZ': ':UTC', 'AWS_LAMBDA_FUNCTION_TIMEOUT': 900, 'LOCALSTACK_HOSTNAME': '172.17.0.4', 'EDGE_PORT': '4566', 'LOCALSTACK_RUNTIME_ID': '826adaab2cb8475c7c36d201edf5fe9a', 'LOCALSTACK_RUNTIME_ENDPOINT': 'http://172.17.0.4:4566/_localstack_lambda/826adaab2cb
8475c7c36d201edf5fe9a', 'AWS_ENDPOINT_URL': 'http://172.17.0.4:4566', '_HANDLER': 'bootstrap', 'AWS_EXECUTION_ENV': 'Aws_Lambda_provided.al2', 'LOCALSTACK_INIT_LOG_LEVEL': 'debug'}, 'user': None, 'cap_add': None, 'cap_drop': None, 'security_opt': None, 'network': 'bridge', 'dns':
 '172.17.0.4', 'additional_flags': '', 'workdir': None, 'privileged': False, 'labels': None, 'platform': 'linux/amd64', 'ulimits': None}
2023-12-19T08:42:27.120 DEBUG --- [   asgi_gw_4] localstack.packages.api    : Installation of lambda-runtime skipped (already installed).
2023-12-19T08:42:27.120 DEBUG --- [   asgi_gw_4] localstack.packages.api    : Performing runtime setup for already installed package.
2023-12-19T08:42:27.120 DEBUG --- [   asgi_gw_4] l.u.c.docker_sdk_client    : Copying file /usr/lib/localstack/lambda-runtime/v0.1.24-pre/arm64/. into localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a:/
2023-12-19T08:42:27.221 DEBUG --- [   asgi_gw_4] l.u.c.docker_sdk_client    : Copying file /tmp/lambda/awslambda-us-east-1-tasks/localstack-rust-lambda-issue-4e891f84-c749-429a-8e7d-ebe9c62eea69/code/. into localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d
201edf5fe9a:/var/task
2023-12-19T08:42:27.298 DEBUG --- [   asgi_gw_4] l.u.c.docker_sdk_client    : Starting container localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:27.381 DEBUG --- [   asgi_gw_4] l.u.c.container_client     : Getting ipv4 address for container localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a in network bridge.
2023-12-19T08:42:57.085  WARN --- [   Thread-81] l.s.l.i.execution_environm : Execution environment 826adaab2cb8475c7c36d201edf5fe9a for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST timed out during startup. Check for errors during
the startup of your Lambda function and consider increasing the startup timeout via LAMBDA_RUNTIME_ENVIRONMENT_TIMEOUT.
2023-12-19T08:42:57.129 DEBUG --- [   Thread-81] l.s.l.i.execution_environm : Logs from the execution environment 826adaab2cb8475c7c36d201edf5fe9a after startup timeout:
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="No code archives set. Skipping download." func=main.DownloadCodeArchives file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/codearchive.go:21"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="DNS server disabled." func=main.RunDNSRewriter file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:145"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Bootstrap not executable, setting permissions to 0755.../var/task/bootstrap" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:85"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=warning msg="Error setting bootstrap to 0755 permissions: /var/task/bootstrapchmod /var/task/bootstrap: no such file or directory" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda
-runtime-init/cmd/localstack/awsutil.go:88"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Process running as root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:164" euid=0 gid=0 uid=0 username=root
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Process running as non-root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:169" euid=993 gid=990 uid=993 username=sbx_user1051
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] Initializing AWS X-Ray daemon unknown
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Listening on UDP 127.0.0.1:2000
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] Using buffer memory limit of 99 MB
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] 1584 segment buffers allocated
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Using Endpoint read from Config file: http://172.17.0.4:4566
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Using proxy address:
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Fetch region us-east-1 from commandline/config file
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] Using region: us-east-1
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] HTTP Proxy server using X-Ray Endpoint : http://172.17.0.4:4566
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Using Endpoint: http://172.17.0.4:4566
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Debug] Batch size: 10
[lambda 826adaab2cb8475c7c36d201edf5fe9a] 2023-12-19T08:42:27Z [Info] Starting proxy http server on 127.0.0.1:2000
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Starting runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:232"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=info msg="Configure environment for Init Caching." func="go.amzn.com/lambda/rapid.(*rapidContext).acceptInitRequestForInitCaching" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/ra
pid/start.go:552"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Hot reloading disabled." func=main.RunHotReloadingListener file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:162"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=info msg="extensionsDisabledByLayer(/opt/disable-extensions-jwigqn8j) -> stat /opt/disable-extensions-jwigqn8j: no such file or directory" func=go.amzn.com/lambda/rapid.extensionsDisabledByLayer file="/ho
me/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:522"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Received RUNNING: {43605486027818 43605486167443 0 43605486027818 true 0x40067802a0}" func="go.amzn.com/lambda/rapidcore.(*Server).Init" file="/home/runner/work/lambda-runtime-init/lambda-runti
me-init/lambda/rapidcore/server.go:510"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Awaiting initialization of runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:235"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Runtime API Server listening on 127.0.0.1:9001" func="go.amzn.com/lambda/rapi.(*Server).Listen" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapi/server.go:102"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=info msg="Configuring and starting Operator Domain" func=go.amzn.com/lambda/rapid.doOperatorDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:255"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=info msg="Starting runtime domain" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:302"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=warning msg="Cannot list external agents" func=go.amzn.com/lambda/agents.ListExternalAgentPaths file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/agents/agent.go:24" error="open /opt/
extensions: no such file or directory"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Preregister runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:329"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=debug msg="Start runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:349"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=warning msg="First fatal error stored in appctx: Runtime.InvalidEntrypoint" func=go.amzn.com/lambda/appctx.StoreFirstFatalError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/appct
x/appctxutil.go:157"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=error msg="Init failed" func=go.amzn.com/lambda/rapid.handleInitError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/exit.go:109" InvokeID= error="fork/exec /var/task/bootstr
ap: no such file or directory"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=info msg="Error releasing after init failure InitDoneFailed: NotReserved" func="go.amzn.com/lambda/rapidcore.(*Server).AwaitInitialized" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lam
bda/rapidcore/server.go:754"
[lambda 826adaab2cb8475c7c36d201edf5fe9a] time="2023-12-19T08:42:27Z" level=error msg="Runtime init failed to initialize: InitDoneFailed. Exiting." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:238"
[lambda 826adaab2cb8475c7c36d201edf5fe9a]
2023-12-19T08:42:57.129 DEBUG --- [   Thread-81] l.u.c.docker_sdk_client    : Stopping container: localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:57.142 DEBUG --- [   Thread-81] l.u.c.docker_sdk_client    : Removing container: localstack-main-lambda-localstack-rust-lambda-issue-826adaab2cb8475c7c36d201edf5fe9a
2023-12-19T08:42:57.176  INFO --- [   asgi_gw_4] localstack.request.aws     : AWS lambda.Invoke => 500 (ServiceException)
2023-12-19T08:42:58.129 DEBUG --- [   asgi_gw_2] l.s.l.i.assignment         : Starting new environment
2023-12-19T08:42:58.129 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor 09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:42:58.129 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Finished creating service endpoint for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST executor 09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:42:58.129 DEBUG --- [   asgi_gw_2] l.s.l.i.docker_runtime_exe : Assigning container name of localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e to executor 09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:42:58.135 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Creating container with attributes: {'self': <localstack.utils.container_utils.docker_sdk_client.SdkDockerClient object at 0xffff9cb9b690>, 'image_name': 'public.ecr.aws/lambda/provided:al2', 'name': 'l
ocalstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e', 'entrypoint': '/var/rapid/init', 'remove': False, 'interactive': False, 'tty': False, 'detach': False, 'command': None, 'mount_volumes': [], 'ports': <PortMappings: {}>, 'exposed_ports': [], 'en
v_vars': {'AWS_DEFAULT_REGION': 'us-east-1', 'AWS_REGION': 'us-east-1', 'AWS_LAMBDA_FUNCTION_NAME': 'localstack-rust-lambda-issue', 'AWS_LAMBDA_FUNCTION_MEMORY_SIZE': 128, 'AWS_LAMBDA_FUNCTION_VERSION': '$LATEST', 'AWS_LAMBDA_INITIALIZATION_TYPE': 'on-demand', 'AWS_LAMBDA_LOG_GRO
UP_NAME': '/aws/lambda/localstack-rust-lambda-issue', 'AWS_LAMBDA_LOG_STREAM_NAME': '2023/12/19/[$LATEST]09890e461149f2bb1119667f3e5dbc7e', 'AWS_ACCESS_KEY_ID': 'LSIAQAAAAAAAL7FFM3CD', 'AWS_SECRET_ACCESS_KEY': 'd7dWxm7nrf036lbjT69NGZAs9SXes8b/1MdS9xHm', 'AWS_SESSION_TOKEN': 'FQoG
ZXIvYXdzEBYaDaV34IFMdjBp2g1lBrAMAe4LG9i2TleyMgM4GBu3C/V5aBdRXqUvODzwjAEhT/CiQr8CVVsn9P9eQ+HdGwg0iPimQGAHOqUeuzKh+kfAUUjKUL7A1TQDVnRVW7+P/Ergs0vUZWp4Hd9/AI+z2f+7JHdqPrplMhveWpH3UkZlUn1Lx6w2ze7+tS6rBTQ0U2+eG6Rsdq59ZjFI17Cau99kRBmtKFKIressS8qbS9A+PECYjy30zy2KdxZqUvEMQzvnAGZ2TmCiMyr+
ADndMs3/cJ62WtvhaPYTQMPuMsCzAW3zAvQBveC5DTOuD8C2U+3LGsYW9DbUlHLQLvxHj3Y=', 'LAMBDA_TASK_ROOT': '/var/task', 'LAMBDA_RUNTIME_DIR': '/var/runtime', 'AWS_XRAY_CONTEXT_MISSING': 'LOG_ERROR', 'AWS_XRAY_DAEMON_ADDRESS': '127.0.0.1:2000', '_AWS_XRAY_DAEMON_PORT': '2000', '_AWS_XRAY_DAEM
ON_ADDRESS': '127.0.0.1', 'TZ': ':UTC', 'AWS_LAMBDA_FUNCTION_TIMEOUT': 900, 'LOCALSTACK_HOSTNAME': '172.17.0.4', 'EDGE_PORT': '4566', 'LOCALSTACK_RUNTIME_ID': '09890e461149f2bb1119667f3e5dbc7e', 'LOCALSTACK_RUNTIME_ENDPOINT': 'http://172.17.0.4:4566/_localstack_lambda/09890e46114
9f2bb1119667f3e5dbc7e', 'AWS_ENDPOINT_URL': 'http://172.17.0.4:4566', '_HANDLER': 'bootstrap', 'AWS_EXECUTION_ENV': 'Aws_Lambda_provided.al2', 'LOCALSTACK_INIT_LOG_LEVEL': 'debug'}, 'user': None, 'cap_add': None, 'cap_drop': None, 'security_opt': None, 'network': 'bridge', 'dns':
 '172.17.0.4', 'additional_flags': '', 'workdir': None, 'privileged': False, 'labels': None, 'platform': 'linux/amd64', 'ulimits': None}
2023-12-19T08:42:58.153 DEBUG --- [   asgi_gw_2] localstack.packages.api    : Installation of lambda-runtime skipped (already installed).
2023-12-19T08:42:58.153 DEBUG --- [   asgi_gw_2] localstack.packages.api    : Performing runtime setup for already installed package.
2023-12-19T08:42:58.153 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Copying file /usr/lib/localstack/lambda-runtime/v0.1.24-pre/arm64/. into localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e:/
2023-12-19T08:42:58.275 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Copying file /tmp/lambda/awslambda-us-east-1-tasks/localstack-rust-lambda-issue-4e891f84-c749-429a-8e7d-ebe9c62eea69/code/. into localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb11196
67f3e5dbc7e:/var/task
2023-12-19T08:42:58.350 DEBUG --- [   asgi_gw_2] l.u.c.docker_sdk_client    : Starting container localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:42:58.444 DEBUG --- [   asgi_gw_2] l.u.c.container_client     : Getting ipv4 address for container localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e in network bridge.
2023-12-19T08:43:28.130  WARN --- [   Thread-86] l.s.l.i.execution_environm : Execution environment 09890e461149f2bb1119667f3e5dbc7e for function arn:aws:lambda:us-east-1:000000000000:function:localstack-rust-lambda-issue:$LATEST timed out during startup. Check for errors during
the startup of your Lambda function and consider increasing the startup timeout via LAMBDA_RUNTIME_ENVIRONMENT_TIMEOUT.
2023-12-19T08:43:28.164 DEBUG --- [   Thread-86] l.s.l.i.execution_environm : Logs from the execution environment 09890e461149f2bb1119667f3e5dbc7e after startup timeout:
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="DNS server disabled." func=main.RunDNSRewriter file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:145"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="No code archives set. Skipping download." func=main.DownloadCodeArchives file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/codearchive.go:21"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Bootstrap not executable, setting permissions to 0755.../var/task/bootstrap" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:85"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=warning msg="Error setting bootstrap to 0755 permissions: /var/task/bootstrapchmod /var/task/bootstrap: no such file or directory" func=main.getBootstrap file="/home/runner/work/lambda-runtime-init/lambda
-runtime-init/cmd/localstack/awsutil.go:88"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Process running as root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:164" euid=0 gid=0 uid=0 username=root
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Process running as non-root user." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:169" euid=993 gid=990 uid=993 username=sbx_user1051
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] Initializing AWS X-Ray daemon unknown
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Listening on UDP 127.0.0.1:2000
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] Using buffer memory limit of 99 MB
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] 1584 segment buffers allocated
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Using Endpoint read from Config file: http://172.17.0.4:4566
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Using proxy address:
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Fetch region us-east-1 from commandline/config file
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] Using region: us-east-1
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] HTTP Proxy server using X-Ray Endpoint : http://172.17.0.4:4566
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Using Endpoint: http://172.17.0.4:4566
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Debug] Batch size: 10
[lambda 09890e461149f2bb1119667f3e5dbc7e] 2023-12-19T08:42:58Z [Info] Starting proxy http server on 127.0.0.1:2000
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Starting runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:232"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=info msg="Configure environment for Init Caching." func="go.amzn.com/lambda/rapid.(*rapidContext).acceptInitRequestForInitCaching" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/ra
pid/start.go:552"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=info msg="extensionsDisabledByLayer(/opt/disable-extensions-jwigqn8j) -> stat /opt/disable-extensions-jwigqn8j: no such file or directory" func=go.amzn.com/lambda/rapid.extensionsDisabledByLayer file="/ho
me/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:522"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Received RUNNING: {43636544736207 43636544850207 0 43636544736207 true 0x4000422d20}" func="go.amzn.com/lambda/rapidcore.(*Server).Init" file="/home/runner/work/lambda-runtime-init/lambda-runti
me-init/lambda/rapidcore/server.go:510"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Hot reloading disabled." func=main.RunHotReloadingListener file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/awsutil.go:162"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Awaiting initialization of runtime init." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:235"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Runtime API Server listening on 127.0.0.1:9001" func="go.amzn.com/lambda/rapi.(*Server).Listen" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapi/server.go:102"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=info msg="Configuring and starting Operator Domain" func=go.amzn.com/lambda/rapid.doOperatorDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:255"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=info msg="Starting runtime domain" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:302"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=warning msg="Cannot list external agents" func=go.amzn.com/lambda/agents.ListExternalAgentPaths file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/agents/agent.go:24" error="open /opt/
extensions: no such file or directory"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Preregister runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:329"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=debug msg="Start runtime" func=go.amzn.com/lambda/rapid.doRuntimeDomainInit file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/start.go:349"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=warning msg="First fatal error stored in appctx: Runtime.InvalidEntrypoint" func=go.amzn.com/lambda/appctx.StoreFirstFatalError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/appct
x/appctxutil.go:157"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=error msg="Init failed" func=go.amzn.com/lambda/rapid.handleInitError file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lambda/rapid/exit.go:109" InvokeID= error="fork/exec /var/task/bootstr
ap: no such file or directory"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=info msg="Error releasing after init failure InitDoneFailed: NotReserved" func="go.amzn.com/lambda/rapidcore.(*Server).AwaitInitialized" file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/lam
bda/rapidcore/server.go:754"
[lambda 09890e461149f2bb1119667f3e5dbc7e] time="2023-12-19T08:42:58Z" level=error msg="Runtime init failed to initialize: InitDoneFailed. Exiting." func=main.main file="/home/runner/work/lambda-runtime-init/lambda-runtime-init/cmd/localstack/main.go:238"
[lambda 09890e461149f2bb1119667f3e5dbc7e]
2023-12-19T08:43:28.165 DEBUG --- [   Thread-86] l.u.c.docker_sdk_client    : Stopping container: localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:43:28.169 DEBUG --- [   Thread-86] l.u.c.docker_sdk_client    : Removing container: localstack-main-lambda-localstack-rust-lambda-issue-09890e461149f2bb1119667f3e5dbc7e
2023-12-19T08:43:28.215  INFO --- [   asgi_gw_2] localstack.request.aws     : AWS lambda.Invoke => 500 (ServiceException)
```
</details>
