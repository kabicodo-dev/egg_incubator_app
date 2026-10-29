'use strict';

// Read-only exporter; stdout is an interchange artifact, never a live upload.
const {loadKit}=require('./support/int_imp_01_mocks.cjs');
const kit=loadKit();
console.log(JSON.stringify({
  kit_revision:kit.manifest.kit_revision,
  classification:kit.manifest.classification,
  active_implementation:kit.manifest.active_implementation,
  sources:kit.manifest,
  wire_references:kit.wires.map(({reference_id,source_filename,source_sha256,lines})=>({reference_id,source_filename,source_sha256,raw_ascii_frames:lines})),
  db02_candidate:{revision:kit.manifest.db02_reference.revision,requests:kit.requests,responses:kit.responses}
},null,2));
