import Head from "next/head";
import { Inter } from "@next/font/google";
import styles from "@/styles/Home.module.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, useContractRead } from "wagmi";
import { abi } from "./abi";
import { ethers } from "ethers";
import { useEffect, useState } from "react";

const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  const { address } = useAccount();
  const [hasHydrated, setHasHydrated] = useState(false);
  useEffect(() => {
    setHasHydrated(true);
  }, []);

  const {
    data: squares,
    isError,
    isLoading,
  } = useContractRead({
    abi,
    address: process.env.NEXT_PUBLIC_GOERLI_CONTRACT_ADDRESS,
    functionName: "getSquares",
  });
  return (
    <>
      <Head>
        <title>Superbowl Squares</title>
        <meta name="description" content="Generated by create next app" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <main className={styles.main}>
        <ConnectButton />
        {squares && !isLoading && !isError && hasHydrated ? (
          <div className="grid gap-1 grid-cols-10 grid-rows-10">
            {(squares as any[]).map((square, i) => (
              <div key={"square" + i}>
                {square !== "0x0000000000000000000000000000000000000000"
                  ? "Y"
                  : "X"}
              </div>
            ))}
          </div>
        ) : null}
      </main>
    </>
  );
}
