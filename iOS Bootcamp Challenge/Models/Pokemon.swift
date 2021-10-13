//
//  Pokemon.swift
//  iOS Bootcamp Challenge
//
//  Created by Jorge Benavides on 26/09/21.
//

import Foundation

// MARK: - Pokemon

enum PokemonType: String, Decodable, CaseIterable, Identifiable {

    var id: String { rawValue }

    case fire = "Fire"
    case grass = "Grass"
    case water = "Water"
    case poison = "Poison"
    case flying = "Flying"
    case electric = "Electric"
    case bug = "Bug"
    case normal = "Normal"
    case fighting = "Fighting"
    case ice = "Ice"
    case ground = "Ground"

}

struct SlotType: Decodable, Equatable {
    let slot: Int
    let type: TypeDescription
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(TypeDescription.self, forKey: .type)
        self.slot = try container.decode(Int.self, forKey: .slot)
    }
    
    enum CodingKeys: String, CodingKey {
        case slot
        case type
    }
}

struct TypeDescription: Decodable, Equatable {
    let name: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

struct Abilities: Decodable, Equatable {
    let ability : TypeDescription
    let slot: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ability = try container.decode(TypeDescription.self, forKey: .ability)
        self.slot = try container.decode(Int.self, forKey: .slot)
    }
    
    enum CodingKeys: String, CodingKey {
        case ability
        case slot
    }
    
}
struct Pokemon: Decodable, Equatable {

    let id: Int
    let name: String
    let image: String?
    let types: [String]?
    let abilities: [String]?
    let weight: Float
    let baseExperience: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case type
        case types
        case sprites
        case other
        case officialArtwork = "official-artwork"
        case frontDefault = "front_default"
        case abilities
        case ability
        case weight
        case baseExperience = "base_experience"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let sprites = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sprites)
        let other = try sprites.nestedContainer(keyedBy: CodingKeys.self, forKey: .other)
        let officialArtWork = try other.nestedContainer(keyedBy: CodingKeys.self, forKey: .officialArtwork)
        self.image = try? officialArtWork.decode(String.self, forKey: .frontDefault)

        // TODO: Decode list of types & abilities
        
        let decodedTypes = try container.decode([SlotType].self, forKey: .types)
        var types: [String] = []
        for slotType in decodedTypes {
           types.append(slotType.type.name)
        }
        self.types = types

        let decodedAbilities = try container.decode([Abilities].self, forKey: .abilities)
        var abilities: [String] = []
        for ability in decodedAbilities {
            abilities.append(ability.ability.name)
        }
        self.abilities = abilities

        self.weight = try container.decode(Float.self, forKey: .weight)
        self.baseExperience = try container.decode(Int.self, forKey: .baseExperience)
    }

}

extension Pokemon {

    func formattedNumber() -> String {
        String(format: "#%03d", arguments: [id])
    }

    func primaryType() -> String? {
        guard let primary = types?.first else { return nil }
        return primary.capitalized
    }

    func secondaryType() -> String? {
        let index = 1
        guard index < types?.count ?? 0 else { return nil }
        return types?[index].capitalized
    }

}
