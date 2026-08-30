//
//  AcknowledgmentsCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13p, Batch 1 — R13p-11's attribution obligation, shipped with the
//  phase: SQLCipher Community Edition's license permits closed commercial
//  use with attribution only, and the obligation is a user-accessible
//  surface carrying the Zetetic copyright line, the license text, and
//  dependency notices. The TEXTS live here (shared — Batch 4's phone face
//  renders the same words); the Mac face is Settings ▸ Acknowledgments.
//
//  Every license text below is copied VERBATIM from the resolved package
//  checkout (or the vendored provenance README) it attributes — never from
//  memory. Sources: .build/checkouts/SQLCipher.swift/LICENSE.md,
//  .build/checkouts/GRDB.swift/LICENSE,
//  .build/checkouts/swift-dependencies/LICENSE, Vendor/CArgon2/README.md,
//  Vendor/BIP39/README.md.
//

import Foundation

nonisolated enum AcknowledgmentsCopy {
    struct Notice: Identifiable, Sendable {
        var id: String { name }
        let name: String
        /// One line saying what it is and why it is here.
        let role: String
        /// The license/provenance text, verbatim where a license applies.
        let text: String
    }

    /// The one-sentence frame the surface leads with.
    static let intro = """
        Variorum is built on open-source software. The encryption that \
        protects your library is SQLCipher, by Zetetic LLC.
        """

    static let all: [Notice] = [sqlcipher, sqlite, grdb, swiftDependencies, argon2, bip39]

    // MARK: - SQLCipher (the R13p-11 obligation)

    static let sqlcipher = Notice(
        name: "SQLCipher",
        role: "Whole-library encryption — every page of your store is "
            + "encrypted at rest with AES-256 through SQLCipher Community "
            + "Edition (Zetetic LLC).",
        text: """
            Copyright (c) 2025, ZETETIC LLC
            All rights reserved.

            Redistribution and use in source and binary forms, with or without
            modification, are permitted provided that the following conditions are met:
                * Redistributions of source code must retain the above copyright
                  notice, this list of conditions and the following disclaimer.
                * Redistributions in binary form must reproduce the above copyright
                  notice, this list of conditions and the following disclaimer in the
                  documentation and/or other materials provided with the distribution.
                * Neither the name of the ZETETIC LLC nor the
                  names of its contributors may be used to endorse or promote products
                  derived from this software without specific prior written permission.

            THIS SOFTWARE IS PROVIDED BY ZETETIC LLC ''AS IS'' AND ANY
            EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
            WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
            DISCLAIMED. IN NO EVENT SHALL ZETETIC LLC BE LIABLE FOR ANY
            DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
            (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
            LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
            ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
            (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
            SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
            """)

    static let sqlite = Notice(
        name: "SQLite",
        role: "The database engine SQLCipher extends, and the store's whole "
            + "substrate.",
        text: """
            The SQLite source code is in the public domain. See
            https://sqlite.org/copyright.html for details.
            """)

    // MARK: - The Swift dependencies

    static let grdb = Notice(
        name: "GRDB.swift",
        role: "The Swift SQLite toolkit every read and write flows through "
            + "(built here from a fork whose one delta is the "
            + "README-documented SQLCipher configuration).",
        text: """
            Copyright (C) 2015-2025 Gwendal Roué

            Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
            """)

    static let swiftDependencies = Notice(
        name: "swift-dependencies",
        role: "Point-Free's dependency-injection library — how the app's "
            + "clocks, identities, and stores stay testable.",
        text: """
            MIT License

            Copyright (c) 2022 Point-Free, Inc.

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.
            """)

    // MARK: - The vendored pieces (Phase 14b)

    static let argon2 = Notice(
        name: "Argon2 (PHC reference implementation)",
        role: "Passphrase key derivation for the encryption passphrase — "
            + "vendored byte-verbatim from the Password Hashing Competition "
            + "winner's official repository.",
        text: """
            Argon2 reference source code package - reference C implementations

            Copyright 2015
            Daniel Dinu, Dmitry Khovratovich, Jean-Philippe Aumasson, and Samuel Neves

            You may use this work under the terms of a Creative Commons CC0 1.0
            License/Waiver or the Apache Public License 2.0, at your option.
            Upstream: https://github.com/P-H-C/phc-winner-argon2
            """)

    static let bip39 = Notice(
        name: "BIP-39 English wordlist",
        role: "The 2,048 words your recovery phrase is drawn from.",
        text: """
            From the Bitcoin Improvement Proposals repository (BIP-0039) —
            PD/BSD-2-Clause per the BIP's preamble; the wordlist is treated as
            public-domain reference data across BIP-39 implementations.
            Upstream: https://github.com/bitcoin/bips/tree/master/bip-0039
            """)
}
