-module('tgen_two-fer').

-behaviour(tgen).

-export([
    revision/0,
    prepare_test_module/0,
    generate_test/2
]).

revision() ->
    1.

prepare_test_module() ->
    AssertStringEqual = tgs:raw("-define(assertStringEqual(Expect, Expr),
        begin ((fun () ->
            __X = (Expect),
            __Y = (Expr),
            case string:equal(__X, __Y) of
                true -> ok;
                false -> erlang:error({assertStringEqual,
                    [{module, ?MODULE},
                     {line, ?LINE},
                     {expression, (??Expr)},
                     {expected, unicode:characters_to_list(__X)},
                     {value, unicode:characters_to_list(__Y)}]})
            end
        end)())
    end)."),

    UnderscoreAssertStringEqual = tgs:raw("-define(_assertStringEqual(Expect, Expr), ?_test(?assertStringEqual(Expect, Expr)))."),

    {ok, [AssertStringEqual, UnderscoreAssertStringEqual]}.

generate_test(N, #{description := Desc, expected := Exp, property := Prop, input := #{name := null}}) ->
    TestName = tgen:to_test_name(N, Desc),
    Property = tgen:to_property_name(Prop),

    Fn = tgs:simple_fun(TestName ++ "_", [
        erl_syntax:tuple([
            tgs:value(binary_to_list(Desc)),
            tgs:call_macro("_assertStringEqual", [
                tgs:value(binary_to_list(Exp)),
                tgs:call_fun("two_fer:" ++ Property, [])])])]),

    {ok, Fn, [{Property, []}]};
generate_test(N, #{description := Desc, expected := Exp, property := Prop, input := #{name := Name}}) ->
    TestName = tgen:to_test_name(N, Desc),
    Property = tgen:to_property_name(Prop),

    Fn = tgs:simple_fun(TestName ++ "_", [
        erl_syntax:tuple([
            tgs:value(binary_to_list(Desc)),
            tgs:call_macro("_assertStringEqual", [
                tgs:value(binary_to_list(Exp)),
                tgs:call_fun("two_fer:" ++ Property, [
                    tgs:value(binary_to_list(Name))])])])]),

    {ok, Fn, [{Property, ["Name"]}]}.
