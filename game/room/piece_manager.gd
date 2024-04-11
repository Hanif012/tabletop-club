# tabletop-club
# Copyright (c) 2020-2024 Benjamin 'drwhut' Beddows.
# Copyright (c) 2021-2024 Tabletop Club contributors (see game/CREDITS.tres).
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name PieceManager
extends IndexManager

## Manage the game pieces throughout the scene that can be added and removed.


## The name of the group of pieces that are about to be removed from the scene.
const ABOUT_TO_REMOVE_GROUP := "rem_pcs"

## The amount of time inbetween "limbo passes", which is the mechanism used to
## remove pieces from the scene tree.
const LIMBO_PASS_INTERVAL_SEC := 3.0


# The amount of time that has passed since the last limbo pass.
var _time_since_limbo_pass_sec := 0.0


func _process(delta: float):
	_time_since_limbo_pass_sec += delta
	if _time_since_limbo_pass_sec > LIMBO_PASS_INTERVAL_SEC:
		_perform_limbo_pass()
		_time_since_limbo_pass_sec = 0.0


## Add a piece to the scene with the given index, and return it.
func add_piece(index: int, scene_entry: AssetEntryScene, transform: Transform) -> Piece:
	var builder := ObjectBuilder.new()
	var piece := builder.build_piece(scene_entry)
	
	piece.transform = transform
	piece.mode = RigidBody.MODE_STATIC
	
	add_child_with_index(index, piece)
	
	return piece


## Request the server to remove one or more pieces given by their indices.
##
## The operation will always "succeed", but some pieces may not be removed for
## various reasons. A list of these indices will be returned to the original
## caller via [method response_remove_mutliple]. For the pieces that are valid
## to be removed, [method reverb_remove_mutliple] is called on all clients.
master func request_remove_multiple(piece_index_arr: PoolIntArray) -> void:
	var caller_id := get_tree().get_rpc_sender_id()
	
	var to_remove_arr := PoolIntArray()
	var ignore_arr := PoolIntArray()
	
	for index in piece_index_arr:
		var piece: Piece = get_child_with_index(index)
		if piece == null:
			ignore_arr.push_back(index)
			continue
		
		if piece.is_in_limbo():
			ignore_arr.push_back(index)
			continue
		
		to_remove_arr.push_back(index)
	
	rpc_id(caller_id, "response_remove_multiple", ignore_arr)
	
	if not to_remove_arr.empty():
		rpc("reverb_remove_multiple", to_remove_arr)


## Called by the server as a response to [method request_remove_multiple].
##
## If any pieces were not removed as a result of the request, they are given as
## as the argument.
puppetsync func response_remove_multiple(rejected_index_arr: PoolIntArray) -> void:
	if not rejected_index_arr.empty():
		push_warning("Server could not remove %d pieces while completing our request" % rejected_index_arr.size())


## Called by the server on all clients to remove one or more pieces from the
## room.
puppetsync func reverb_remove_multiple(piece_index_arr: PoolIntArray) -> void:
	for index in piece_index_arr:
		var piece: Piece = get_child_with_index(index)
		if piece == null:
			push_error("Cannot remove piece '%d', piece does not exist" % index)
			continue
		
		if piece.is_in_limbo():
			push_warning("Cannot put piece '%d' in limbo, already in limbo" % index)
			continue
		
		piece.put_in_limbo()


# Perform a "limbo pass", where all of the pieces currently in limbo are marked
# for removal, and all of the pieces that are marked for removal are removed
# from the scene tree.
func _perform_limbo_pass() -> void:
	get_tree().call_group(ABOUT_TO_REMOVE_GROUP, "queue_free")
	
	for element in get_tree().get_nodes_in_group(Piece.LIMBO_GROUP):
		var piece_in_limbo: Piece = element
		piece_in_limbo.add_to_group(ABOUT_TO_REMOVE_GROUP)
