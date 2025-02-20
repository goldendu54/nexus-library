---
--- Melon's Masks
--- https://github.com/melonstuff/melonsmasks/
--- Licensed under MIT
---

----
---@module
---@name masks
---@realm CLIENT
----
---- An alternative to stencils that samples a texture
---- For reference:
----  The destination is what is being masked, so a multi stage gradient or some other complex stuff
----  The source is the text, or the thing with alpha
----
local masks = {}
--- youraddon.masks = masks

masks.source = {}
masks.dest   = {}

masks.source.rt = GetRenderTargetEx("MelonMasks_Source",      ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
masks.dest.rt   = GetRenderTargetEx("MelonMasks_Destination", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

masks.source.mat = CreateMaterial("MelonMasks_Source", "UnlitGeneric", {
    ["$basetexture"] = masks.source.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})
masks.dest.mat    = CreateMaterial("MelonMasks_Destination", "UnlitGeneric", {
    ["$basetexture"] = masks.dest.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})


----
---@enumeration
---@name masks.KIND
----
---@enum (CUT)   Cuts the source out of the destination
---@enum (STAMP) Cuts the destination out of the source
----
---- Determines the type of mask were rendering
----
masks.KIND_CUT   = {BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD}
masks.KIND_STAMP = {BLEND_ZERO, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD}

----
---@name masks.Start
----
----
---- Starts the mask destination render
---- Whats between this and the `masks.Source` call is the destination
---- See the module declaration for an explaination
----
function masks.Start()
    render.PushRenderTarget(masks.dest.rt)
    render.Clear(0, 0, 0, 0, true, true)
    cam.Start2D()
end

----
---@name masks.Source
----
---- Stops the destination render
---- Whats between this and the `masks.End` call is the source
---- See the module declaration for an explaination
----
function masks.Source()
    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(masks.source.rt)
    render.Clear(0, 0, 0, 0, true, true)
    cam.Start2D()
end

----
---@name masks.And
----
---@arg (kind: masks.KIND_) The kind of mask this is, remember this is not a number enum
----
---- Renders the given kind of mask and continues the mask render
---- This can be used to layer masks 
---- This must be called post [masks.Source]
---- You still need to call End
----
function masks.And(kind)
    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    masks.Source()
end

----
---@name masks.End
----
---@arg (kind: masks.KIND_) The kind of mask this is, remember this is not a number enum
---@arg (x:         number) The x coordinate to render the rectangle at, defaults to 0
---@arg (y:         number) The y coordinate to render the rectangle at, defaults to 0
---@arg (w:         number) The width of the rectangle to render
---@arg (h:         number) The height of the rectangle to render
----
---- Stops the source render and renders everything finally
---- See the module declaration for an explaination
----
function masks.End(kind, x, y, w, h)
    kind = kind or masks.KIND_CUT

    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    cam.End2D()
    render.PopRenderTarget()

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(masks.dest.mat)
    surface.DrawTexturedRect(x or 0, y or 0, w or ScrW(), h or ScrH())
end

----
---@name masks.EndToTexture
----
---@arg (tex:     ITexture)
---@arg (kind: masks.KIND_) The kind of mask this is, remember this is not a number enum
----
---- Stops the source render and renders everything to the given ITexture
----
function masks.EndToTexture(texture, kind)
    kind = kind or masks.KIND_CUT

    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    cam.End2D()
    render.PopRenderTarget()

    if IsValid(texture) then
        render.CopyTexture(masks.dest.rt, texture)
    end
end

Nexus.Masks = masks
