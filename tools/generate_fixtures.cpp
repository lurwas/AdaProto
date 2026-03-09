#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

#include "fixtures/schema.pb.h"

namespace {

void write_file(const std::string& path, const std::string& data) {
  std::ofstream out(path, std::ios::binary);
  if (!out) {
    throw std::runtime_error("cannot open " + path);
  }
  out.write(data.data(), static_cast<std::streamsize>(data.size()));
}

std::string to_hex(const std::string& data) {
  std::ostringstream oss;
  oss << std::hex << std::setfill('0');
  for (unsigned char c : data) {
    oss << std::setw(2) << static_cast<int>(c);
  }
  return oss.str();
}

fixtures::AllTypes build_diff_case_from_seed(std::uint64_t seed) {
  fixtures::AllTypes msg;

  const std::int32_t i32 = static_cast<std::int32_t>((seed * 1103515245ULL + 12345ULL) % 2000001ULL) - 1000000;
  const std::uint64_t u64 = (seed * 6364136223846793005ULL + 1442695040888963407ULL);
  const std::int32_t s32 = static_cast<std::int32_t>((seed * 214013ULL + 2531011ULL) % 200001ULL) - 100000;
  const std::int64_t s64 = static_cast<std::int64_t>((seed * 11400714819323198485ULL) ^ 0xA5A5A5A5A5A5A5A5ULL);

  msg.set_int32_f(i32);
  msg.set_uint64_f(u64);
  msg.set_sint32_f(s32);
  msg.set_sint64_f(s64);
  msg.set_string_f("seed-" + std::to_string(seed));
  msg.set_bytes_f(std::string({static_cast<char>(seed & 0xFF), static_cast<char>((seed >> 8) & 0xFF), static_cast<char>(0xAA)}));

  auto* nested = msg.mutable_nested_f();
  nested->set_id(static_cast<std::int32_t>((seed % 10000ULL) - 5000ULL));
  nested->set_note("n-" + std::to_string(seed % 97ULL));

  msg.add_repeated_int32(i32);
  msg.add_repeated_int32(-i32);
  msg.add_repeated_int32(static_cast<std::int32_t>(seed % 1000ULL));

  msg.add_packed_sint32(s32);
  msg.add_packed_sint32(-s32);
  msg.add_packed_sint32(static_cast<std::int32_t>((seed % 101ULL) - 50ULL));

  return msg;
}

}  // namespace

int main() {
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  fixtures::AllTypes msg;
  msg.set_int32_f(-123);
  msg.set_int64_f(-4567890123LL);
  msg.set_uint32_f(3000000000U);
  msg.set_uint64_f(1234567890123456789ULL);
  msg.set_sint32_f(-321);
  msg.set_sint64_f(-6543219876543LL);
  msg.set_bool_f(true);
  msg.set_fixed32_f(0xDEADBEEF);
  msg.set_fixed64_f(0x0123456789ABCDEFULL);
  msg.set_sfixed32_f(-2222);
  msg.set_sfixed64_f(-3333333333LL);
  msg.set_float_f(3.5f);
  msg.set_double_f(-12345.6789);
  msg.set_string_f("hello ada");
  msg.set_bytes_f(std::string("\x00\x01\xFE", 3));
  auto* nested = msg.mutable_nested_f();
  nested->set_id(7);
  nested->set_note("nested");
  msg.add_repeated_int32(1);
  msg.add_repeated_int32(-1);
  msg.add_repeated_int32(150);
  msg.add_packed_sint32(-1);
  msg.add_packed_sint32(0);
  msg.add_packed_sint32(1);
  msg.add_packed_sint32(150);
  msg.add_packed_sint32(-150);

  std::string all_types;
  msg.SerializeToString(&all_types);
  write_file("fixtures/all_types.bin", all_types);
  write_file("fixtures/all_types.hex", to_hex(all_types));

  fixtures::AllTypes empty;
  std::string empty_bytes;
  empty.SerializeToString(&empty_bytes);
  write_file("fixtures/empty.bin", empty_bytes);
  write_file("fixtures/empty.hex", to_hex(empty_bytes));

  fixtures::AdvancedTypes advanced;
  advanced.set_choice_text("selected");
  advanced.add_packed_fixed64(0x1122334455667788ULL);
  advanced.add_packed_fixed64(0xFFEEDDCCBBAA0099ULL);
  advanced.add_chunks(std::string());
  advanced.add_chunks(std::string("\x00\xAB\xCD", 3));
  advanced.set_flag(true);
  advanced.set_utf8("hello-advanced");
  advanced.set_blob(std::string("\x00\x7F\x80\xFF", 4));
  auto* advanced_nested = advanced.mutable_nested();
  advanced_nested->set_id(-42);
  advanced_nested->set_note("edge");

  std::string advanced_bytes;
  advanced.SerializeToString(&advanced_bytes);
  write_file("fixtures/advanced_types.bin", advanced_bytes);
  write_file("fixtures/advanced_types.hex", to_hex(advanced_bytes));

  std::ofstream corpus("fixtures/all_types_corpus.hex");
  if (!corpus) {
    throw std::runtime_error("cannot open fixtures/all_types_corpus.hex");
  }
  for (std::uint64_t seed = 1; seed <= 128; ++seed) {
    fixtures::AllTypes c = build_diff_case_from_seed(seed);
    std::string encoded;
    c.SerializeToString(&encoded);
    corpus << to_hex(encoded) << "\n";
  }

  google::protobuf::ShutdownProtobufLibrary();
  return 0;
}
