// First, indirect drawing; similar to basic point cloud step, should be drawing
// quads at point positions

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    // information passed from vertex shader to fragment shader
    @location(0) @interpolate(flat) sort_color: vec4<f32>
};

struct Splat {
    // information defined in preprocess compute shader
    // relevant for culling and atomic count
    pos: u32, // ndc
    size: u32, // quad
    conic_opacity: array<u32, 2>, // conic xyz and opacity
    color: array<u32, 2> // rgb
};

@group(0) @binding(0) var<storage, read> splats: array<Splat>;
@group(0) @binding(1) var<storage, read> sort_indices: array<u32>;

@vertex
fn vs_main( @builtin(vertex_index) iv: u32,
            @builtin(instance_index) ii: u32
) -> VertexOutput {
    // reconstruct 2D quad based on information from splat, pass 
    var quad = array<vec2<f32>, 6> (
        vec2(-1.0, -1.0), 
        vec2(1.0, -1.0), 
        vec2(1.0, 1.0),
        vec2(-1.0, -1.0), 
        vec2(1.0, 1.0), 
        vec2(-1.0, 1.0)
    );

    let s = splats[sort_indices[ii]];
    let center = unpack2x16float(s.pos);
    let size = unpack2x16float(s.size);

    var out: VertexOutput;
    out.position = vec4<f32>(center + quad[iv] * size , 0., 1.);
    out.sort_color = vec4<f32>(size.x, size.y, 0.0, 1.0);
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return in.sort_color;
}