-- @description 恢复选中 Take 的名称为原始文件名
-- @author Gemini
-- @version 1.0

function RestoreOriginalNames()
    local count = reaper.CountSelectedMediaItems(0)
    
    if count == 0 then
        reaper.ShowMessageBox("请先选中要恢复名称的音频物品！", "提示", 0)
        return
    end

    reaper.Undo_BeginBlock()

    for i = 0, count - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        
        if take and not reaper.TakeIsMIDI(take) then
            -- 获取音频源文件
            local source = reaper.GetMediaItemTake_Source(take)
            -- 获取文件的完整路径
            local full_path = reaper.GetMediaSourceFileName(source, "")
            
            if full_path ~= "" then
                -- 从完整路径中提取文件名（处理反斜杠和正斜杠）
                local filename = full_path:match("([^/\\]+)$")
                
                if filename then
                    -- 将 Take 名称设为提取到的文件名
                    reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", filename, true)
                end
            end
        end
    end

    reaper.Undo_EndBlock("恢复原始文件名", -1)
    reaper.UpdateArrange()
end

RestoreOriginalNames()
