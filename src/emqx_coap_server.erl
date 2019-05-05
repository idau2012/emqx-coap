%% Copyright (c) 2013-2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(emqx_coap_server).

-include("emqx_coap.hrl").

-export([ start/0
        , stop/0
        ]).

start() ->
    {ok, _} = application:ensure_all_started(gen_coap),
    {ok, _} = coap_server:start_udp(coap_udp_socket, application:get_env(?APP, port, 5683)),
    case application:get_env(?APP, dtls_port) of
        {ok, DtlsPort} ->
            CACertFile = application:get_env(?APP, cacertfile, ""),
            CertFile = application:get_env(?APP, certfile, ""),
            KeyFile = application:get_env(?APP, keyfile, ""),
            {ok, _} = coap_server:start_dtls(coap_dtls_socket, DtlsPort, [{certfile, CertFile}, {keyfile, KeyFile}, {cacertfile, CACertFile}]);
        _ ->
            ok
    end,
    ok = coap_server_registry:add_handler([<<"mqtt">>], emqx_coap_resource, undefined),
    ok = coap_server_registry:add_handler([<<"ps">>], emqx_coap_ps_resource, undefined).

stop() ->
    application:stop(gen_coap).

