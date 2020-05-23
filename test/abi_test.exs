defmodule ABITest do
  use ExUnit.Case
  doctest ABI

  import ABI

  alias ABI.FunctionSelector

  describe "parse_specification/1" do
    test "parses an ABI" do
      abi = [
        %{
          "constant" => true,
          "inputs" => [
            %{
              "type" => "uint256",
              "name" => "foo"
            }
          ],
          "name" => "fooBar",
          "outputs" => [
            %{
              "name" => "foo",
              "type" => "uint256[6]"
            },
            %{
              "name" => "bar",
              "type" => "bool"
            },
            %{
              "name" => "baz",
              "type" => "uint256[3]"
            },
            %{
              "name" => "buz",
              "type" => "string"
            }
          ],
          "payable" => false,
          "type" => "function"
        },
        %{
          "name" => "baz",
          "type" => "function",
          "outputs" => [
            %{
              "name" => "",
              "type" => "tuple",
              "components" => [
                %{
                  "name" => "foo",
                  "type" => "uint256"
                },
                %{
                  "name" => "bar",
                  "type" => "uint256"
                }
              ]
            },
            %{
              "name" => "",
              "type" => "string"
            }
          ],
          "inputs" => []
        },
        %{
          "name" => "sam",
          "type" => "function",
          "inputs" => [
            %{
              "type" => "bytes",
              "name" => "foo"
            },
            %{
              "type" => "bool",
              "name" => "bar"
            },
            %{
              "type" => "uint256[]",
              "name" => "baz"
            }
          ],
          "outputs" => [
            %{
              "name" => "",
              "type" => "tuple",
              "components" => [
                %{
                  "name" => "",
                  "type" => "uint256"
                },
                %{
                  "name" => "",
                  "type" => "uint256"
                }
              ]
            },
            %{
              "name" => "",
              "type" => "string"
            }
          ]
        }
      ]

      expected = [
        %FunctionSelector{
          type: :function,
          function: "fooBar",
          input_names: ["foo"],
          types: [{:uint, 256}],
          returns: [{:array, {:uint, 256}, 6}, :bool, {:array, {:uint, 256}, 3}, :string],
          method_id: <<245, 72, 246, 70>>
        },
        %FunctionSelector{
          type: :function,
          function: "baz",
          types: [],
          returns: [{:tuple, [{:uint, 256}, {:uint, 256}]}, :string],
          method_id: <<167, 145, 111, 172>>
        },
        %FunctionSelector{
          type: :function,
          function: "sam",
          input_names: ["foo", "bar", "baz"],
          types: [:bytes, :bool, {:array, {:uint, 256}}],
          returns: [{:tuple, [{:uint, 256}, {:uint, 256}]}, :string],
          method_id: <<165, 100, 59, 242>>
        }
      ]

      assert parse_specification(abi) == expected
    end
  end

  describe "find_and_decode/2" do
    test "finds and decode the correct function" do
      function_specs = [
        %ABI.FunctionSelector{
          function: "startInFlightExit",
          input_names: [
            "inFlightTx",
            "inputTxs",
            "inputUtxosPos",
            "inputTxsInclusionProofs",
            "inFlightTxWitnesses"
          ],
          inputs_indexed: nil,
          method_id: <<90, 82, 133, 20>>,
          returns: [],
          type: :function,
          types: [
            tuple: [
              :bytes,
              {:array, :bytes},
              {:array, {:uint, 256}},
              {:array, :bytes},
              {:array, :bytes}
            ]
          ]
        }
      ]

      data =
        <<90, 82, 133, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 160, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 126, 248,
          124, 1, 225, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 1, 210, 32, 127, 180, 0, 246, 245, 1, 243, 148, 118, 78, 248, 3, 28, 17, 248,
          220, 42, 92, 18, 141, 145, 248, 79, 186, 190, 47, 160, 172, 148, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 69, 99, 145, 130, 68, 244, 0, 0, 128, 160, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 93, 248, 91, 1, 192, 246, 245, 1, 243, 148, 118, 78,
          248, 3, 28, 17, 248, 220, 42, 92, 18, 141, 145, 248, 79, 186, 190, 47, 160, 172, 148, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 138, 199, 35, 4, 137, 232,
          0, 0, 128, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 210, 32, 127, 180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 243,
          154, 134, 159, 98, 231, 92, 245, 240, 191, 145, 70, 136, 166, 178, 137, 202, 242, 4,
          148, 53, 216, 230, 140, 92, 94, 109, 5, 228, 73, 19, 243, 78, 213, 192, 45, 109, 72,
          200, 147, 36, 134, 201, 157, 58, 217, 153, 229, 216, 148, 157, 195, 190, 59, 48, 88,
          204, 41, 121, 105, 12, 62, 58, 98, 28, 121, 43, 20, 191, 102, 248, 42, 243, 111, 0, 245,
          251, 167, 1, 79, 160, 193, 226, 255, 60, 124, 39, 59, 254, 82, 60, 26, 207, 103, 220,
          63, 95, 160, 128, 166, 134, 165, 160, 208, 92, 61, 72, 34, 253, 84, 214, 50, 220, 156,
          192, 75, 22, 22, 4, 110, 186, 44, 228, 153, 235, 154, 247, 159, 94, 185, 73, 105, 10, 4,
          4, 171, 244, 206, 186, 252, 124, 255, 250, 56, 33, 145, 183, 221, 158, 125, 247, 120,
          88, 30, 111, 183, 142, 250, 179, 95, 211, 100, 201, 213, 218, 218, 212, 86, 155, 109,
          212, 127, 127, 234, 186, 250, 53, 113, 248, 66, 67, 68, 37, 84, 131, 53, 172, 110, 105,
          13, 208, 113, 104, 216, 188, 91, 119, 151, 156, 26, 103, 2, 51, 79, 82, 159, 87, 131,
          247, 158, 148, 47, 210, 205, 3, 246, 229, 90, 194, 207, 73, 110, 132, 159, 222, 156, 68,
          111, 171, 70, 168, 210, 125, 177, 227, 16, 15, 39, 90, 119, 125, 56, 91, 68, 227, 203,
          192, 69, 202, 186, 201, 218, 54, 202, 224, 64, 173, 81, 96, 130, 50, 76, 150, 18, 124,
          242, 159, 69, 53, 235, 91, 126, 186, 207, 226, 161, 214, 211, 170, 184, 236, 4, 131,
          211, 32, 121, 168, 89, 255, 112, 249, 33, 89, 112, 168, 190, 235, 177, 193, 100, 196,
          116, 232, 36, 56, 23, 76, 142, 235, 111, 188, 140, 180, 89, 75, 136, 201, 68, 143, 29,
          64, 176, 155, 234, 236, 172, 91, 69, 219, 110, 65, 67, 74, 18, 43, 105, 92, 90, 133,
          134, 45, 142, 174, 64, 179, 38, 143, 111, 55, 228, 20, 51, 123, 227, 142, 186, 122, 181,
          187, 243, 3, 208, 31, 75, 122, 224, 127, 215, 62, 220, 47, 59, 224, 94, 67, 148, 138,
          52, 65, 138, 50, 114, 80, 156, 67, 194, 129, 26, 130, 30, 92, 152, 43, 165, 24, 116,
          172, 125, 201, 221, 121, 168, 12, 194, 240, 95, 111, 102, 76, 157, 187, 46, 69, 68, 53,
          19, 125, 160, 108, 228, 77, 228, 85, 50, 165, 106, 58, 112, 7, 162, 208, 198, 180, 53,
          247, 38, 249, 81, 4, 191, 166, 231, 7, 4, 111, 193, 84, 186, 233, 24, 152, 208, 58, 26,
          10, 198, 249, 180, 94, 71, 22, 70, 226, 85, 90, 199, 158, 63, 232, 126, 177, 120, 30,
          38, 242, 5, 0, 36, 12, 55, 146, 116, 254, 145, 9, 110, 96, 209, 84, 90, 128, 69, 87, 31,
          218, 185, 181, 48, 208, 214, 231, 232, 116, 110, 120, 191, 159, 32, 244, 232, 111, 6, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 65, 52, 191, 197, 222, 130, 0, 246, 100, 25, 133, 115, 123, 250,
          19, 77, 122, 226, 50, 133, 34, 71, 195, 27, 188, 147, 104, 200, 235, 121, 231, 64, 251,
          107, 58, 88, 55, 118, 117, 53, 9, 224, 81, 93, 0, 167, 62, 195, 202, 233, 207, 237, 254,
          185, 95, 207, 246, 144, 69, 242, 160, 58, 161, 96, 70, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>

      assert {
               %ABI.FunctionSelector{
                 function: "startInFlightExit",
                 input_names: [
                   "inFlightTx",
                   "inputTxs",
                   "inputUtxosPos",
                   "inputTxsInclusionProofs",
                   "inFlightTxWitnesses"
                 ],
                 inputs_indexed: nil,
                 method_id: <<90, 82, 133, 20>>,
                 returns: [],
                 type: :function,
                 types: [
                   tuple: [
                     :bytes,
                     {:array, :bytes},
                     {:array, {:uint, 256}},
                     {:array, :bytes},
                     {:array, :bytes}
                   ]
                 ]
               },
               [
                 {<<248, 124, 1, 225, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 1, 210, 32, 127, 180, 0, 246, 245, 1, 243, 148, 118,
                    78, 248, 3, 28, 17, 248, 220, 42, 92, 18, 141, 145, 248, 79, 186, 190, 47,
                    160, 172, 148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    136, 69, 99, 145, 130, 68, 244, 0, 0, 128, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
                  [
                    <<248, 91, 1, 192, 246, 245, 1, 243, 148, 118, 78, 248, 3, 28, 17, 248, 220,
                      42, 92, 18, 141, 145, 248, 79, 186, 190, 47, 160, 172, 148, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 138, 199, 35, 4, 137, 232,
                      0, 0, 128, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
                  ], [2_002_000_000_000],
                  [
                    <<243, 154, 134, 159, 98, 231, 92, 245, 240, 191, 145, 70, 136, 166, 178, 137,
                      202, 242, 4, 148, 53, 216, 230, 140, 92, 94, 109, 5, 228, 73, 19, 243, 78,
                      213, 192, 45, 109, 72, 200, 147, 36, 134, 201, 157, 58, 217, 153, 229, 216,
                      148, 157, 195, 190, 59, 48, 88, 204, 41, 121, 105, 12, 62, 58, 98, 28, 121,
                      43, 20, 191, 102, 248, 42, 243, 111, 0, 245, 251, 167, 1, 79, 160, 193, 226,
                      255, 60, 124, 39, 59, 254, 82, 60, 26, 207, 103, 220, 63, 95, 160, 128, 166,
                      134, 165, 160, 208, 92, 61, 72, 34, 253, 84, 214, 50, 220, 156, 192, 75, 22,
                      22, 4, 110, 186, 44, 228, 153, 235, 154, 247, 159, 94, 185, 73, 105, 10, 4,
                      4, 171, 244, 206, 186, 252, 124, 255, 250, 56, 33, 145, 183, 221, 158, 125,
                      247, 120, 88, 30, 111, 183, 142, 250, 179, 95, 211, 100, 201, 213, 218, 218,
                      212, 86, 155, 109, 212, 127, 127, 234, 186, 250, 53, 113, 248, 66, 67, 68,
                      37, 84, 131, 53, 172, 110, 105, 13, 208, 113, 104, 216, 188, 91, 119, 151,
                      156, 26, 103, 2, 51, 79, 82, 159, 87, 131, 247, 158, 148, 47, 210, 205, 3,
                      246, 229, 90, 194, 207, 73, 110, 132, 159, 222, 156, 68, 111, 171, 70, 168,
                      210, 125, 177, 227, 16, 15, 39, 90, 119, 125, 56, 91, 68, 227, 203, 192, 69,
                      202, 186, 201, 218, 54, 202, 224, 64, 173, 81, 96, 130, 50, 76, 150, 18,
                      124, 242, 159, 69, 53, 235, 91, 126, 186, 207, 226, 161, 214, 211, 170, 184,
                      236, 4, 131, 211, 32, 121, 168, 89, 255, 112, 249, 33, 89, 112, 168, 190,
                      235, 177, 193, 100, 196, 116, 232, 36, 56, 23, 76, 142, 235, 111, 188, 140,
                      180, 89, 75, 136, 201, 68, 143, 29, 64, 176, 155, 234, 236, 172, 91, 69,
                      219, 110, 65, 67, 74, 18, 43, 105, 92, 90, 133, 134, 45, 142, 174, 64, 179,
                      38, 143, 111, 55, 228, 20, 51, 123, 227, 142, 186, 122, 181, 187, 243, 3,
                      208, 31, 75, 122, 224, 127, 215, 62, 220, 47, 59, 224, 94, 67, 148, 138, 52,
                      65, 138, 50, 114, 80, 156, 67, 194, 129, 26, 130, 30, 92, 152, 43, 165, 24,
                      116, 172, 125, 201, 221, 121, 168, 12, 194, 240, 95, 111, 102, 76, 157, 187,
                      46, 69, 68, 53, 19, 125, 160, 108, 228, 77, 228, 85, 50, 165, 106, 58, 112,
                      7, 162, 208, 198, 180, 53, 247, 38, 249, 81, 4, 191, 166, 231, 7, 4, 111,
                      193, 84, 186, 233, 24, 152, 208, 58, 26, 10, 198, 249, 180, 94, 71, 22, 70,
                      226, 85, 90, 199, 158, 63, 232, 126, 177, 120, 30, 38, 242, 5, 0, 36, 12,
                      55, 146, 116, 254, 145, 9, 110, 96, 209, 84, 90, 128, 69, 87, 31, 218, 185,
                      181, 48, 208, 214, 231, 232, 116, 110, 120, 191, 159, 32, 244, 232, 111, 6>>
                  ],
                  [
                    <<52, 191, 197, 222, 130, 0, 246, 100, 25, 133, 115, 123, 250, 19, 77, 122,
                      226, 50, 133, 34, 71, 195, 27, 188, 147, 104, 200, 235, 121, 231, 64, 251,
                      107, 58, 88, 55, 118, 117, 53, 9, 224, 81, 93, 0, 167, 62, 195, 202, 233,
                      207, 237, 254, 185, 95, 207, 246, 144, 69, 242, 160, 58, 161, 96, 70, 28>>
                  ]}
               ]
             } = ABI.find_and_decode(function_specs, data)
    end
  end

  test "decodes string tuple" do
    signature = "(string)"

    encoded_data =
      <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 11, 69, 116, 104, 101, 114, 32, 84, 111, 107, 101, 110, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>

    params = [{"Ether Token"}]

    assert ABI.decode(
             signature,
             encoded_data
           ) == params

    assert ABI.encode(signature, params) == encoded_data
  end

  test "decodes startStandardExit((uint256,bytes,bytes))" do
    signature = "(uint256,bytes,bytes)"

    params = [
      {5_000_000_000_000,
       <<248, 116, 1, 225, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 3, 163, 142, 47, 10, 0, 238, 237, 1, 235, 148, 34, 212, 145, 189, 226, 48,
         63, 47, 67, 50, 91, 33, 8, 210, 111, 30, 171, 161, 227, 43, 148, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 128, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
       <<243, 154, 134, 159, 98, 231, 92, 245, 240, 191, 145, 70, 136, 166, 178, 137, 202, 242, 4,
         148, 53, 216, 230, 140, 92, 94, 109, 5, 228, 73, 19, 243, 78, 213, 192, 45, 109, 72, 200,
         147, 36, 134, 201, 157, 58, 217, 153, 229, 216, 148, 157, 195, 190, 59, 48, 88, 204, 41,
         121, 105, 12, 62, 58, 98, 28, 121, 43, 20, 191, 102, 248, 42, 243, 111, 0, 245, 251, 167,
         1, 79, 160, 193, 226, 255, 60, 124, 39, 59, 254, 82, 60, 26, 207, 103, 220, 63, 95, 160,
         128, 166, 134, 165, 160, 208, 92, 61, 72, 34, 253, 84, 214, 50, 220, 156, 192, 75, 22,
         22, 4, 110, 186, 44, 228, 153, 235, 154, 247, 159, 94, 185, 73, 105, 10, 4, 4, 171, 244,
         206, 186, 252, 124, 255, 250, 56, 33, 145, 183, 221, 158, 125, 247, 120, 88, 30, 111,
         183, 142, 250, 179, 95, 211, 100, 201, 213, 218, 218, 212, 86, 155, 109, 212, 127, 127,
         234, 186, 250, 53, 113, 248, 66, 67, 68, 37, 84, 131, 53, 172, 110, 105, 13, 208, 113,
         104, 216, 188, 91, 119, 151, 156, 26, 103, 2, 51, 79, 82, 159, 87, 131, 247, 158, 148,
         47, 210, 205, 3, 246, 229, 90, 194, 207, 73, 110, 132, 159, 222, 156, 68, 111, 171, 70,
         168, 210, 125, 177, 227, 16, 15, 39, 90, 119, 125, 56, 91, 68, 227, 203, 192, 69, 202,
         186, 201, 218, 54, 202, 224, 64, 173, 81, 96, 130, 50, 76, 150, 18, 124, 242, 159, 69,
         53, 235, 91, 126, 186, 207, 226, 161, 214, 211, 170, 184, 236, 4, 131, 211, 32, 121, 168,
         89, 255, 112, 249, 33, 89, 112, 168, 190, 235, 177, 193, 100, 196, 116, 232, 36, 56, 23,
         76, 142, 235, 111, 188, 140, 180, 89, 75, 136, 201, 68, 143, 29, 64, 176, 155, 234, 236,
         172, 91, 69, 219, 110, 65, 67, 74, 18, 43, 105, 92, 90, 133, 134, 45, 142, 174, 64, 179,
         38, 143, 111, 55, 228, 20, 51, 123, 227, 142, 186, 122, 181, 187, 243, 3, 208, 31, 75,
         122, 224, 127, 215, 62, 220, 47, 59, 224, 94, 67, 148, 138, 52, 65, 138, 50, 114, 80,
         156, 67, 194, 129, 26, 130, 30, 92, 152, 43, 165, 24, 116, 172, 125, 201, 221, 121, 168,
         12, 194, 240, 95, 111, 102, 76, 157, 187, 46, 69, 68, 53, 19, 125, 160, 108, 228, 77,
         228, 85, 50, 165, 106, 58, 112, 7, 162, 208, 198, 180, 53, 247, 38, 249, 81, 4, 191, 166,
         231, 7, 4, 111, 193, 84, 186, 233, 24, 152, 208, 58, 26, 10, 198, 249, 180, 94, 71, 22,
         70, 226, 85, 90, 199, 158, 63, 232, 126, 177, 120, 30, 38, 242, 5, 0, 36, 12, 55, 146,
         116, 254, 145, 9, 110, 96, 209, 84, 90, 128, 69, 87, 31, 218, 185, 181, 48, 208, 214,
         231, 232, 116, 110, 120, 191, 159, 32, 244, 232, 111, 6>>}
    ]

    expected_result =
      <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
        140, 39, 57, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 118, 248, 116, 1, 225, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 163, 142, 47, 10, 0, 238, 237, 1,
        235, 148, 34, 212, 145, 189, 226, 48, 63, 47, 67, 50, 91, 33, 8, 210, 111, 30, 171, 161,
        227, 43, 148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 128, 160, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 243, 154, 134, 159, 98, 231, 92, 245, 240, 191,
        145, 70, 136, 166, 178, 137, 202, 242, 4, 148, 53, 216, 230, 140, 92, 94, 109, 5, 228, 73,
        19, 243, 78, 213, 192, 45, 109, 72, 200, 147, 36, 134, 201, 157, 58, 217, 153, 229, 216,
        148, 157, 195, 190, 59, 48, 88, 204, 41, 121, 105, 12, 62, 58, 98, 28, 121, 43, 20, 191,
        102, 248, 42, 243, 111, 0, 245, 251, 167, 1, 79, 160, 193, 226, 255, 60, 124, 39, 59, 254,
        82, 60, 26, 207, 103, 220, 63, 95, 160, 128, 166, 134, 165, 160, 208, 92, 61, 72, 34, 253,
        84, 214, 50, 220, 156, 192, 75, 22, 22, 4, 110, 186, 44, 228, 153, 235, 154, 247, 159, 94,
        185, 73, 105, 10, 4, 4, 171, 244, 206, 186, 252, 124, 255, 250, 56, 33, 145, 183, 221,
        158, 125, 247, 120, 88, 30, 111, 183, 142, 250, 179, 95, 211, 100, 201, 213, 218, 218,
        212, 86, 155, 109, 212, 127, 127, 234, 186, 250, 53, 113, 248, 66, 67, 68, 37, 84, 131,
        53, 172, 110, 105, 13, 208, 113, 104, 216, 188, 91, 119, 151, 156, 26, 103, 2, 51, 79, 82,
        159, 87, 131, 247, 158, 148, 47, 210, 205, 3, 246, 229, 90, 194, 207, 73, 110, 132, 159,
        222, 156, 68, 111, 171, 70, 168, 210, 125, 177, 227, 16, 15, 39, 90, 119, 125, 56, 91, 68,
        227, 203, 192, 69, 202, 186, 201, 218, 54, 202, 224, 64, 173, 81, 96, 130, 50, 76, 150,
        18, 124, 242, 159, 69, 53, 235, 91, 126, 186, 207, 226, 161, 214, 211, 170, 184, 236, 4,
        131, 211, 32, 121, 168, 89, 255, 112, 249, 33, 89, 112, 168, 190, 235, 177, 193, 100, 196,
        116, 232, 36, 56, 23, 76, 142, 235, 111, 188, 140, 180, 89, 75, 136, 201, 68, 143, 29, 64,
        176, 155, 234, 236, 172, 91, 69, 219, 110, 65, 67, 74, 18, 43, 105, 92, 90, 133, 134, 45,
        142, 174, 64, 179, 38, 143, 111, 55, 228, 20, 51, 123, 227, 142, 186, 122, 181, 187, 243,
        3, 208, 31, 75, 122, 224, 127, 215, 62, 220, 47, 59, 224, 94, 67, 148, 138, 52, 65, 138,
        50, 114, 80, 156, 67, 194, 129, 26, 130, 30, 92, 152, 43, 165, 24, 116, 172, 125, 201,
        221, 121, 168, 12, 194, 240, 95, 111, 102, 76, 157, 187, 46, 69, 68, 53, 19, 125, 160,
        108, 228, 77, 228, 85, 50, 165, 106, 58, 112, 7, 162, 208, 198, 180, 53, 247, 38, 249, 81,
        4, 191, 166, 231, 7, 4, 111, 193, 84, 186, 233, 24, 152, 208, 58, 26, 10, 198, 249, 180,
        94, 71, 22, 70, 226, 85, 90, 199, 158, 63, 232, 126, 177, 120, 30, 38, 242, 5, 0, 36, 12,
        55, 146, 116, 254, 145, 9, 110, 96, 209, 84, 90, 128, 69, 87, 31, 218, 185, 181, 48, 208,
        214, 231, 232, 116, 110, 120, 191, 159, 32, 244, 232, 111, 6>>

    assert ABI.encode(signature, params) == expected_result
    assert ABI.decode(signature, expected_result) == params
  end
end
