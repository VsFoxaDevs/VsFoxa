---@funkinScript

local stuff = {
  disabled = false,
  anims = {
    ['singleft'] = {-60, 'x'},
    ['singdown'] = {60, 'y'},
    ['singup'] = {-60, 'y'},
    ['singright'] = {60, 'x'},
    ['singleft-loop'] = {-60, 'x'},
    ['singdown-loop'] = {60, 'y'},
    ['singup-loop'] = {-60, 'y'},
    ['singright-loop'] = {60, 'x'},
  },
  check = {
    [true] = 'boyfriend',
    [false] = 'dad',
  },
}

function onUpdatePost(elapsed)
  if stuff.disabled then return end
  local character = stuff.check[mustHitSection]
  local name = getProperty(character..'.animation.curAnim.name'):lower();
  local anim_info = stuff.anims[name]
  if anim_info then
    local offset = anim_info[1]
    local axis = anim_info[2]
    local follow = (not version:find('0.7') and 'camFollowPos' or 'camGame.scroll')..'.'
    local var = follow..axis
    local currentPos = getProperty(var);
    setProperty(var, currentPos + offset * math.max(0, math.min(elapsed / getProperty('cameraSpeed') * playbackRate, 1)));
  end
end