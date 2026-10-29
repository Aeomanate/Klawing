#include <iostream>
#include <string>

// CLI11
#include <CLI/CLI.hpp>

// spdlog
#include <spdlog/spdlog.h>

// reflect-cpp
#include <rfl.hpp>
#include <rfl/json.hpp>

// Google Test
#include <gtest/gtest.h>

// Google Protobuf
#include <google/protobuf/stubs/common.h>

// Boost Asio (version header)
#include <boost/asio/version.hpp>

// SFML
#include <SFML/System.hpp>
#include <SFML/Window.hpp>
#include <SFML/Graphics.hpp>
#include <SFML/Network.hpp>
#include <SFML/Audio.hpp>

struct LibraryInfo {
    std::string name;
    std::string status;
};

template <typename T>
[[maybe_unused]] T input(std::string_view prompt) {
    std::print(std::cout,"{}", prompt);
    T value;
    if constexpr (std::is_same_v<T, std::string>) {
        std::getline(std::cin, value);
    } else {
        while (!(std::cin >> value)) {
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::print(std::cout, "Invalid input. Try again: ");
        }
    }
    return value;
}

int main(int argc, char** argv)
{
    // 1. CLI11
    CLI::App app{"Klawing Application"};
    bool verbose = false;
    app.add_flag("-v,--verbose", verbose, "Enable verbose output");
    CLI11_PARSE(app, argc, argv);

    // 2. spdlog
    spdlog::info("Demonstrating all fetched libraries in minimal main:");

    // 3. reflect-cpp
    LibraryInfo lib_info{.name = "reflect-cpp", .status = "operational"};
    const std::string json_str = rfl::json::write(lib_info);
    spdlog::info(" - reflect-cpp: {}", json_str);

    // 4. Google Test
    testing::InitGoogleTest(&argc, argv);
    spdlog::info(" - Google Test initialized");

    // 5. Protobuf
    spdlog::info(" - Protobuf version: {}", GOOGLE_PROTOBUF_VERSION);

    // 6. Boost.Asio
    spdlog::info(" - Boost.Asio version: {}.{}.{}",
                 BOOST_ASIO_VERSION / 100000,
                 (BOOST_ASIO_VERSION / 100) % 1000,
                 BOOST_ASIO_VERSION % 100);

    // 7. SFML
    const sf::Vector2f position{100.0f, 200.0f};
    const sf::Color color = sf::Color::Green;
    const sf::VideoMode mode({800u, 600u});
    const sf::IpAddress localhost = sf::IpAddress::LocalHost;
    const sf::Time duration = sf::seconds(1.0f);

    spdlog::info(" - SFML Position: ({}, {}), Color: (r={}, g={}, b={}, a={})",
                 position.x, position.y, color.r, color.g, color.b, color.a);
    spdlog::info(" - SFML VideoMode: {}x{}, Duration: {}s, Host: {}",
                 mode.size.x, mode.size.y, duration.asSeconds(), localhost.toString());

    spdlog::info("All fetched libraries successfully demonstrated.");

    input<std::string>("Any questions?\n -> ");
    std::cout << "Good, find answers. Bye!";
    input<std::string>("");

    return 0;
}