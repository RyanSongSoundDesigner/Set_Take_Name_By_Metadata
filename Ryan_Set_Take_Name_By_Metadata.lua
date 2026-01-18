-- @description 仅当有描述元数据时重命名选中的 Take，否则保持原名
-- @author Gemini
-- @version 1.2

function RenameItems()
    local count = reaper.CountSelectedMediaItems(0)
    
    if count == 0 then
        reaper.ShowMessageBox("请先选中至少一个音频物品！", "提示", 0)
        return
    end

    reaper.Undo_BeginBlock()

    for i = 0, count - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        
        -- 确保是音频文件且存在 Take
        if take and not reaper.TakeIsMIDI(take) then
            local source = reaper.GetMediaItemTake_Source(take)
            local metadata_content = ""
            
            -- 定义查找“描述”的优先级标签
            local tags_to_check = {
                "DESCRIPTION",
                "DESC",
                "COMMENT",
                "BWF:Description",
                "INFO:ICMT",
                "TITLE"
            }
            
            -- 尝试获取元数据
            for _, tag in ipairs(tags_to_check) do
                local retval, buf = reaper.GetMediaFileMetadata(source, tag)
                if retval > 0 and buf ~= "" then
                    metadata_content = buf
                    break 
                end
            end
            
            -- 核心逻辑修改：只有当 metadata_content 不为空时，才执行改名
            if metadata_content ~= "" then
                reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", metadata_content, true)
            end
            -- 如果为空，则什么都不做，保留原名
        end
    end

    reaper.Undo_EndBlock("根据元数据重命名（无则跳过）", -1)
    reaper.UpdateArrange()
end

RenameItems()
